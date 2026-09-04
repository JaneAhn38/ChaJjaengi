<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<html>
<head>
<link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
<link rel="stylesheet" href="../resources/css/theme.css" />
<title>로그인 | 차쟁이</title>
</head>
<body>

<jsp:include page="../common/menu.jsp" />

<div class="page-hero">
	<h1>회원 로그인</h1>
	<p>Membership Login</p>
</div>

<div class="auth-card">
	<h3><i class="fa-solid fa-right-to-bracket" style="color:var(--figma-point-red);"></i> Please sign in</h3>
	<%
		String error = request.getParameter("error");
		if (error != null) {
			out.println("<div class='alert alert-danger mb-3'>");
			out.println("아이디와 비밀번호를 확인해 주세요");
			out.println("</div>");
		}
	%>
	<% String csrfToken = util.CsrfUtil.getOrCreateToken(session); %>
	<form action="${pageContext.request.contextPath}/processLoginMember" method="post">
		<input type="hidden" name="_csrf" value="<%= csrfToken %>">
		<div class="mb-3">
			<label class="form-label">ID</label>
			<input type="text" class="form-control" name='id' placeholder="아이디" required autofocus>
		</div>
		<div class="mb-4">
			<label class="form-label">Password</label>
			<input type="password" class="form-control" name='password' placeholder="비밀번호">
		</div>

		<button class="btn btn-figma-primary w-100" type="submit">
			<i class="fa-solid fa-right-to-bracket"></i> 로그인
		</button>
	</form>

	<div class="text-center mt-4" style="font-size:0.9rem; color:var(--figma-text-gray);">
		아직 계정이 없으신가요?
		<a href="${pageContext.request.contextPath}/member/addMember.jsp" style="color:var(--figma-point-red); font-weight:700; text-decoration:none;">회원가입</a>
	</div>
</div>

<jsp:include page="../common/footer.jsp" />
</body>
</html>
