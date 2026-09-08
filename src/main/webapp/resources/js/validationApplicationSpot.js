function CheckAddSpot() {
    const form = document.forms["newApplicationSpot"];
    const spotName = form["spotName"].value.trim();
    const category = form.querySelector('input[name="category"]:checked');
    const reason   = form["application_reason"].value.trim();

    const addressBase   = document.getElementById("spotAddressBase").value.trim();
    const addressDetail = document.getElementById("spotAddressDetail").value.trim();

    if (!spotName) {
        showAlert("장소명을 입력해주세요.");
        return false;
    }

    if (spotName.length > 50) {
        showAlert("장소명은 50자 이하로 입력해주세요.");
        return false;
    }

    if (!addressBase) {
        showAlert("주소 검색을 눌러 주소를 선택해주세요.");
        return false;
    }

    if (!category) {
        showAlert("카테고리를 선택해주세요.");
        return false;
    }

    if (!reason) {
        showAlert("장소 등록 이유를 입력해주세요.");
        return false;
    }

    // 주소 검색으로 찾은 기본 주소 + 직접 입력한 상세 주소를 합쳐서 전송
    document.getElementById("spot_address").value =
        addressDetail ? (addressBase + " " + addressDetail) : addressBase;

    return true;
}
