package util;

import jakarta.servlet.http.Part;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Cloudinary(무료 이미지 호스팅)에 이미지를 업로드하는 유틸.
 *
 * Render처럼 배포할 때마다 컨테이너를 새로 만드는 환경에서는, 런타임에 로컬
 * 디스크(webapps/ROOT/resources/images)에 저장한 업로드 파일이 다음 배포 때
 * 통째로 사라진다. 그래서 실제 파일은 Cloudinary에 올리고 DB에는 그 파일의
 * URL만 저장한다 (재배포와 무관하게 유지됨).
 *
 * 서명 업로드(signed upload) 방식이라 Cloudinary 콘솔에서 업로드 프리셋을
 * 따로 만들 필요 없이, 대시보드에 바로 보이는 Cloud Name/API Key/API Secret
 * 세 개만 있으면 된다.
 * https://cloudinary.com/documentation/upload_images#generating_authentication_signatures
 */
public class CloudinaryUtil {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "gif", "webp");

    private static final String CLOUD_NAME = env("CLOUDINARY_CLOUD_NAME", "");
    private static final String API_KEY    = env("CLOUDINARY_API_KEY", "");
    private static final String API_SECRET = env("CLOUDINARY_API_SECRET", "");

    private static String env(String key, String fallback) {
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) return prop;
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : fallback;
    }

    public static boolean isConfigured() {
        return !CLOUD_NAME.isBlank() && !API_KEY.isBlank() && !API_SECRET.isBlank();
    }

    /**
     * 이미지를 검증 후 Cloudinary에 업로드하고, 접근 가능한 URL을 반환한다.
     *
     * @throws IllegalArgumentException 허용되지 않는 확장자인 경우
     * @throws Exception                업로드 자체가 실패한 경우 (환경변수 누락, 네트워크 오류 등)
     */
    public static String uploadImage(Part filePart) throws Exception {
        String original = filePart.getSubmittedFileName();
        String name = (original != null) ? Paths.get(original).getFileName().toString() : "upload";
        String ext = "";
        int dotIdx = name.lastIndexOf('.');
        if (dotIdx >= 0) ext = name.substring(dotIdx + 1).toLowerCase();

        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new IllegalArgumentException("허용되지 않는 파일 형식입니다: " + ext
                    + " (허용: jpg, jpeg, png, gif, webp)");
        }

        if (!isConfigured()) {
            throw new IllegalStateException("CLOUDINARY_CLOUD_NAME / CLOUDINARY_API_KEY / "
                    + "CLOUDINARY_API_SECRET 환경변수가 설정되지 않았습니다.");
        }

        long timestamp = System.currentTimeMillis() / 1000;
        String signature = sha1Hex("timestamp=" + timestamp + API_SECRET);

        String boundary = "ChajjaengiBoundary" + UUID.randomUUID();
        byte[] body = buildMultipartBody(boundary, filePart, name, timestamp, signature);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.cloudinary.com/v1_1/" + CLOUD_NAME + "/image/upload"))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .timeout(Duration.ofSeconds(20))
                .POST(HttpRequest.BodyPublishers.ofByteArray(body))
                .build();

        HttpResponse<String> response = HttpClient.newHttpClient()
                .send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new RuntimeException("Cloudinary 업로드 실패 (" + response.statusCode() + "): " + response.body());
        }

        Matcher m = Pattern.compile("\"secure_url\"\\s*:\\s*\"([^\"]+)\"").matcher(response.body());
        if (m.find()) {
            return m.group(1).replace("\\/", "/");
        }
        throw new RuntimeException("Cloudinary 응답에서 secure_url을 찾지 못했습니다: " + response.body());
    }

    private static String sha1Hex(String s) throws Exception {
        MessageDigest sha1 = MessageDigest.getInstance("SHA-1");
        byte[] hash = sha1.digest(s.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private static byte[] buildMultipartBody(String boundary, Part filePart, String filename,
                                              long timestamp, String signature) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        writeField(out, boundary, "api_key", API_KEY);
        writeField(out, boundary, "timestamp", String.valueOf(timestamp));
        writeField(out, boundary, "signature", signature);

        String contentType = filePart.getContentType() != null ? filePart.getContentType() : "application/octet-stream";
        out.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Disposition: form-data; name=\"file\"; filename=\"" + filename + "\"\r\n")
                .getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Type: " + contentType + "\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        try (InputStream input = filePart.getInputStream()) {
            input.transferTo(out);
        }
        out.write("\r\n".getBytes(StandardCharsets.UTF_8));
        out.write(("--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
        return out.toByteArray();
    }

    private static void writeField(ByteArrayOutputStream out, String boundary, String name, String value) throws Exception {
        out.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        out.write((value + "\r\n").getBytes(StandardCharsets.UTF_8));
    }
}
