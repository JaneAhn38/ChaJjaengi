const POST_IMAGE_MAX_MB   = 5;
const POST_IMAGE_MAX_COUNT = 5;
const POST_IMAGE_ALLOWED   = ["image/jpeg", "image/png", "image/gif", "image/webp"];

function validatePostForm() {
    const title   = document.getElementById("title").value.trim();
    const content = document.getElementById("content").value.trim();
    const fileInput = document.getElementById("postImages");

    if (!title) {
        showAlert("제목을 입력해주세요.");
        document.getElementById("title").focus();
        return false;
    }
    if (title.length > 100) {
        showAlert("제목은 100자 이하로 입력해주세요.");
        document.getElementById("title").focus();
        return false;
    }

    if (!content) {
        showAlert("내용을 입력해주세요.");
        document.getElementById("content").focus();
        return false;
    }
    if (content.length < 5) {
        showAlert("내용을 5자 이상 입력해주세요.");
        document.getElementById("content").focus();
        return false;
    }
    if (content.length > 5000) {
        showAlert("내용은 5000자 이하로 입력해주세요. (현재 " + content.length + "자)");
        document.getElementById("content").focus();
        return false;
    }

    if (fileInput && fileInput.files.length > 0) {
        if (fileInput.files.length > POST_IMAGE_MAX_COUNT) {
            showAlert("이미지는 최대 " + POST_IMAGE_MAX_COUNT + "장까지 첨부할 수 있습니다.");
            return false;
        }
        for (const file of fileInput.files) {
            if (!POST_IMAGE_ALLOWED.includes(file.type)) {
                showAlert("'" + file.name + "'\n허용되지 않는 파일 형식입니다.\n(허용: jpg, png, gif, webp)");
                return false;
            }
            if (file.size > POST_IMAGE_MAX_MB * 1024 * 1024) {
                showAlert("'" + file.name + "'\n파일 크기가 " + POST_IMAGE_MAX_MB + "MB를 초과합니다.");
                return false;
            }
        }
    }

    return true;
}
