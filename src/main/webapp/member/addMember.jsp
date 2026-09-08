<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>

<head>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link rel="stylesheet" href="../resources/css/theme.css" />
    <title>회원가입 | 차쟁이</title>
	<script src="../resources/js/customAlert.js"></script>
	<script src="../resources/js/validationSignIn.js"></script>
</head>
<body>

<jsp:include page="../common/menu.jsp" />

<div class="page-hero">
    <h1>회원 가입</h1>
    <p>Membership Joining</p>
</div>

<div class="auth-card auth-card-wide">

    <!-- 에러 메시지 -->
    <% String error = request.getParameter("error"); if (error != null) { %>
    <div class="alert alert-danger">
        <% if ("id".equals(error)) { %>아이디를 입력해주세요.
        <% } else if ("password".equals(error)) { %>비밀번호는 8자 이상이어야 합니다.
        <% } else if ("passwordMismatch".equals(error)) { %>비밀번호가 일치하지 않습니다.
        <% } else if ("birth".equals(error)) { %>생년월일을 올바르게 입력해주세요.
        <% } else if ("email".equals(error)) { %>이메일을 올바르게 입력해주세요.
        <% } else if ("dup".equals(error)) { %>이미 사용 중인 아이디 또는 이메일입니다.
        <% } %>
    </div>
    <% } %>

    <!-- 회원가입 폼 -->
    <%  String csrfToken = util.CsrfUtil.getOrCreateToken(session); %>
    <form name="newMember" action="${pageContext.request.contextPath}/processAddMember" method="post" onsubmit="return validateSignInForm()">
        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
        <!-- 아이디, 비밀번호, 비밀번호 확인, 이름 등 기존 폼은 그대로 유지 -->
        <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">아이디</label>
            <div class="col-sm-4">
                <input name="id" type="text" class="form-control" placeholder="id">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">비밀번호</label>
            <div class="col-sm-4">
                <input name="password" type="password" class="form-control" placeholder="password">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">비밀번호확인</label>
            <div class="col-sm-4">
                <input name="password_confirm" type="password" class="form-control" placeholder="password confirm">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2 col-form-label">성명</label>
            <div class="col-sm-4">
                <input name="name" type="text" class="form-control" placeholder="name">
            </div>
        </div>

		<div class="mb-3 row">
			<label class="col-sm-2 col-form-label">성별</label>
			<div class="col-sm-4 d-flex align-items-center gap-3">
				<div class="form-check">
					<input class="form-check-input" name="gender" type="radio" value="남" id="genderM" />
					<label class="form-check-label" for="genderM">남</label>
				</div>
				<div class="form-check">
					<input class="form-check-input" name="gender" type="radio" value="여" id="genderF" />
					<label class="form-check-label" for="genderF">여</label>
				</div>
			</div>
		</div>

		<div class="mb-3 row">
			<label class="col-sm-2 col-form-label">생일</label>
			<div class="col-sm-10">
			  <div class="row g-2">
			  	<div class="col-sm-3">
					<input type="text" name="birthyy" maxlength="4"  class="form-control" placeholder="년(4자)">
				</div>
				<div class="col-sm-3">
				<select name="birthmm" class="form-select">
					<option value="">월</option>
					<option value="01">1</option>
					<option value="02">2</option>
					<option value="03">3</option>
					<option value="04">4</option>
					<option value="05">5</option>
					<option value="06">6</option>
					<option value="07">7</option>
					<option value="08">8</option>
					<option value="09">9</option>
					<option value="10">10</option>
					<option value="11">11</option>
					<option value="12">12</option>
				</select>
				</div>
				<div class="col-sm-3">
				<input type="text" name="birthdd" maxlength="2" class="form-control" placeholder="일">
				</div>
			  </div>
			</div>
		</div>

	<div class="mb-3 row">
		<label class="col-sm-2 col-form-label">이메일</label>
			<div class="col-sm-10">
			  <div class="row g-2 align-items-center">
				<div class="col-sm-4">
					<input type="text" name="mail1" maxlength="50" class="form-control"  placeholder="email">
				</div>
				<div class="col-auto">@</div>
				<div class="col-sm-3">
					 <select name="mail2_select" id="mailSelect" class="form-select">
						<option value="naver.com">naver.com</option>
						<option value="daum.net">daum.net</option>
						<option value="gmail.com">gmail.com</option>
						<option value="nate.com">nate.com</option>
						 <option value="custom">직접입력</option>
					</select>
				</div>
				  <div class="col-sm-3">
				  	<input type="text" name="mail2" id="customMail" maxlength="50" class="form-control"  placeholder="입력" style= "display:none;">
				  </div>
				  </div>
			</div>
		</div>
		<div class="mb-3 row">
			<label class="col-sm-2 col-form-label">전화번호</label>
			<div class="col-sm-10">
				<div class="row g-2 align-items-center">
					<div class="col-sm-2">
						<select name="phone1" class="form-select">
							<option value="010">010</option>
							<option value="011">011</option>
							<option value="012">012</option>
							<option value="013">013</option>
							<option value="014">014</option>
							<option value="015">015</option>
							<option value="016">016</option>
							<option value="017">017</option>
							<option value="018">018</option>
							<option value="019">019</option>
						</select>
					</div>
					<div class="col-auto">-</div>
					<div class="col-sm-2">
						<input type="text" name="phone2" maxlength="4" class="form-control" placeholder="0000">
					</div>
					<div class="col-auto">-</div>
					<div class="col-sm-2">
						<input type="text" name="phone3" maxlength="4" class="form-control" placeholder="0000">
					</div>
				</div>
			</div>
		</div>

        <!-- 주소 입력란과 위경도 변환 버튼 추가 -->
        <div class="mb-4 row">
            <label class="col-sm-2 col-form-label">주소</label>
            <div class="col-sm-7">
                <input name="address" id="address" type="text" class="form-control" placeholder="도로명 주소 입력">
            </div>
        </div>

        <!-- 회원가입 제출 버튼 -->
        <div class="row">
            <div class="col-sm-10 offset-sm-2 d-flex gap-2">
                <input type="submit" class="btn btn-figma-primary" value="등록">
                <input type="reset" class="btn btn-figma-secondary" value="취소">
            </div>
        </div>
    </form>

</div>

<jsp:include page="../common/footer.jsp" />
<script>
	document.getElementById("mailSelect").addEventListener("change", function() {
		const customInput = document.getElementById("customMail");

		if (this.value === "custom") {
			customInput.style.display = "block";
		} else {
			customInput.style.display = "none";
			customInput.value = ""; // 기존 값 초기화
		}
	});
</script>
</body>
</html>
