function validateReviewForm() {
    const form = document.forms["newReview"];
    const rating = form["rating"].value;
    const content = form["content"].value.trim();

    // 별점 유효성 검사
    if (!rating || rating < 1 || rating > 5) {
        showAlert("별점을 선택해주세요. (1~5점)");
        return false;
    }

    // 내용 유효성 검사
    if (content === "") {
        showAlert("리뷰 내용을 입력해주세요.");
        return false;
    }

    if (content.length > 1000) {
        showAlert("리뷰는 1000자 이하로 작성해주세요.");
        return false;
    }

    // 유효성 검사 통과
    return true;
}
