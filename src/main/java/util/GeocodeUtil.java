package util;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 카카오 로컬 API(주소 검색)로 주소 문자열을 위도/경도로 변환하는 유틸.
 * https://developers.kakao.com/docs/latest/ko/local/dev-guide#address-coord
 */
public class GeocodeUtil {

    // 카카오 디벨로퍼스 앱의 REST API 키. 코드에 직접 넣지 않고 환경변수(KAKAO_REST_API_KEY)로만 주입.
    private static final String REST_API_KEY = env("KAKAO_REST_API_KEY", "");

    private static String env(String key, String fallback) {
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) return prop;
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : fallback;
    }

    public record Coordinates(double latitude, double longitude) {}

    /** 주소를 위도/경도로 변환. 실패하거나 결과가 없으면 null 반환(호출부에서 0,0으로 폴백). */
    public static Coordinates geocode(String address) {
        if (address == null || address.isBlank()) return null;
        if (REST_API_KEY.isBlank()) {
            System.err.println("GeocodeUtil: KAKAO_REST_API_KEY 환경변수가 설정되지 않았습니다.");
            return null;
        }
        try {
            String encoded = URLEncoder.encode(address, StandardCharsets.UTF_8);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://dapi.kakao.com/v2/local/search/address.json?query=" + encoded))
                    .header("Authorization", "KakaoAK " + REST_API_KEY)
                    .timeout(Duration.ofSeconds(5))
                    .GET()
                    .build();
            HttpResponse<String> response = HttpClient.newHttpClient()
                    .send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                System.err.println("GeocodeUtil: 카카오 API 응답 코드 " + response.statusCode() + " - " + response.body());
                return null;
            }

            // 별도 JSON 라이브러리 없이, 첫 번째 결과의 x(경도)/y(위도)만 정규식으로 추출
            String body = response.body();
            Matcher xMatcher = Pattern.compile("\"x\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
            Matcher yMatcher = Pattern.compile("\"y\"\\s*:\\s*\"([^\"]+)\"").matcher(body);
            if (xMatcher.find() && yMatcher.find()) {
                double lng = Double.parseDouble(xMatcher.group(1));
                double lat = Double.parseDouble(yMatcher.group(1));
                return new Coordinates(lat, lng);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
