function validateSignInForm() {
    const form = document.forms["newMember"];

    const id       = form["id"].value.trim();
    const password = form["password"].value.trim();
    const passwordConfirm = form["password_confirm"].value.trim();
    const name     = form["name"].value.trim();
    const birthyy  = form["birthyy"].value.trim();
    const birthmm  = form["birthmm"].value;
    const birthdd  = form["birthdd"].value.trim();
    const mail1    = form["mail1"].value.trim();
    const mailSelect = form["mail2_select"].value;
    const mail2    = form["mail2"].value.trim();
    // phone은 phone1(select) + phone2 + phone3으로 분리되어 있음
    const phone2   = form["phone2"].value.trim();
    const phone3   = form["phone3"].value.trim();
    const address  = form["address"].value.trim();
    const gender   = form.querySelector('input[name="gender"]:checked');

    const idRegex = /^[a-zA-Z0-9]{8,17}$/;
    const pwRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,20}$/;

    if (!idRegex.test(id)) {
        showAlert("아이디는 영문자와 숫자만 사용하여 8~17자로 입력하세요.");
        return false;
    }

    if (!pwRegex.test(password)) {
        showAlert("비밀번호는 8~20자이며, 영문/숫자/특수문자(!@#$%^&*)를 모두 포함해야 합니다.");
        return false;
    }

    if (password !== passwordConfirm) {
        showAlert("비밀번호가 일치하지 않습니다.");
        return false;
    }

    if (!name) {
        showAlert("이름을 입력하세요.");
        return false;
    }

    if (!gender) {
        showAlert("성별을 선택하세요.");
        return false;
    }

    // birthyy: 4자리 숫자, birthmm: 선택 필수, birthdd: 1~2자리 숫자
    if (!/^\d{4}$/.test(birthyy)) {
        showAlert("태어난 연도를 4자리 숫자로 입력하세요.");
        return false;
    }
    if (!birthmm) {
        showAlert("태어난 월을 선택하세요.");
        return false;
    }
    if (!/^\d{1,2}$/.test(birthdd) || birthdd < 1 || birthdd > 31) {
        showAlert("태어난 일을 올바르게 입력하세요. (1~31)");
        return false;
    }

    if (!mail1) {
        showAlert("이메일 아이디를 입력하세요.");
        return false;
    }
    if (mailSelect === "custom" && !mail2) {
        showAlert("이메일 도메인을 직접 입력하세요.");
        return false;
    }

    // phone2: 3~4자리 숫자, phone3: 4자리 숫자
    if (!/^\d{3,4}$/.test(phone2)) {
        showAlert("전화번호 가운데 자리를 올바르게 입력하세요. (3~4자리)");
        return false;
    }
    if (!/^\d{4}$/.test(phone3)) {
        showAlert("전화번호 끝 자리를 올바르게 입력하세요. (4자리)");
        return false;
    }

    if (!address) {
        showAlert("주소를 입력하세요.");
        return false;
    }

    return true;
}
