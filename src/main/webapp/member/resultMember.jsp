<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
<link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
<title>회원 정보</title>
</head>
<body>

<div class="container py-4">
	<jsp:include page="../common/menu.jsp" />

 <div class="py-4">
      <%
			String msg = request.getParameter("msg");
      		if (msg == null) {
      %>
         <h1 class="fw-bold" style="color:#1C1C1E;">알림</h1>
        <% } else if ("1".equals(msg)) { %>
         <h1 class="fw-bold" style="color:#1C1C1E;">회원 가입</h1>
        <p class="fs-5" style="color:var(--figma-text-gray);">Membership Joining</p>
        <% } else { %>
        <h1 class="fw-bold" style="color:#1C1C1E;">회원 정보</h1>
        <p class="fs-5" style="color:var(--figma-text-gray);">Membership Info</p>
        <% } %>
    </div>


	 <div class="row align-items-md-stretch text-center">
		<%
			if (msg != null) {
				if (msg.equals("0")) //회원 수정
					out.println(" <h2 style='color:#1C1C1E; font-weight:700;'>회원정보가 수정되었습니다.</h2>");
				else if (msg.equals("1")) //회원 가입
					out.println(" <h2 style='color:#1C1C1E; font-weight:700;'>회원가입을 축하드립니다.</h2>");
				else if (msg.equals("2")) { //로그인
					String loginId = (String) session.getAttribute("userId");
					out.println(" <h2 style='color:#1C1C1E; font-weight:700;'>" + loginId + "님 환영합니다</h2>");
				}
			   else if (msg.equals("3")) //가입 탈퇴
				out.println("<h2 style='color:#1C1C1E; font-weight:700;'>회원정보가 삭제되었습니다.</h2>");
			}
		%>
	</div>
	<jsp:include page="../common/footer.jsp" />
</div>	
</body>
</html>