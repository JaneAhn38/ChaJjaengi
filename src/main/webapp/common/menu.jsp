<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
<link rel="stylesheet" href="../resources/css/theme.css" />
<script src="../resources/js/customAlert.js"></script>

<!-- 1번째 줄(로고+로그인 상태): 원래대로 상단 고정 -->
<nav class="custom-nav d-flex justify-content-between align-items-center flex-wrap">
	<div class="nav-left">
		<a href="<c:url value="/index.jsp"/>" class="home-icon-box"><i class="fa-solid fa-house"></i></a>
		<a href="<c:url value="/index.jsp"/>" class="nav-home-text">차쟁이</a>
	</div>

	<div class="nav-right">
		<c:choose>
			<c:when test="${empty sessionScope.userId}">
				<a class="nav-link-item" href="<c:url value="/member/loginMember.jsp"/>">
					<i class="fa-solid fa-right-to-bracket"></i> 로그인</a>
				<a class="nav-signup-btn" href="<c:url value="/member/addMember.jsp"/>">
					<i class="fa-solid fa-user-plus"></i> 회원가입</a>
			</c:when>
			<c:otherwise>
				<span class="nav-user-badge">[<c:out value="${sessionScope.userId}"/>님]</span>
				<form action="${pageContext.request.contextPath}/processLogoutMember" method="post" class="d-inline m-0 p-0">
					<input type="hidden" name="_csrf" value="<%=util.CsrfUtil.getOrCreateToken(session)%>">
					<button type="submit" class="nav-link-item">
						<i class="fa-solid fa-circle-xmark"></i> 로그아웃
					</button>
				</form>
			</c:otherwise>
		</c:choose>
	</div>
</nav>

<!-- 2번째 줄(메뉴 링크): 하단 고정 -->
<div class="bottom-toolbar">
	<div class="sub-nav">
		<div class="sub-nav-inner">
			<a class="nav-link-item" href="<c:url value="/spot/spots.jsp"/>">
				<i class="fa-solid fa-location-dot"></i> 스팟 보기</a>
			<a class="nav-link-item" href="${pageContext.request.contextPath}/community/board.jsp">
				<i class="fa-solid fa-comments"></i> 커뮤니티</a>

			<c:if test="${not empty sessionScope.userId}">
				<a class="nav-link-item" href="${pageContext.request.contextPath}/wishlist/wishlist.jsp">
					<i class="fa-solid fa-heart"></i> 찜목록</a>

				<div class="mypage-dropdown" tabindex="0">
					<span class="mypage-dropdown-toggle">
						<i class="fa-solid fa-user"></i> 마이페이지 <i class="fa-solid fa-chevron-up" style="font-size:0.7em;"></i>
					</span>
					<div class="mypage-dropdown-menu">
						<a href="${pageContext.request.contextPath}/profile/myProfile.jsp">
							<i class="fa-solid fa-user"></i> 내 프로필</a>
						<a href="<c:url value="/member/updateMember.jsp"/>">
							<i class="fa-solid fa-pen-to-square"></i> 개인정보 수정</a>
						<a href="${pageContext.request.contextPath}/spotApplication/myApplications.jsp">
							<i class="fa-solid fa-clipboard-list"></i> 나의 신청 내역</a>
					</div>
				</div>

				<c:if test="${sessionScope.userRole == 'ADMIN'}">
					<a class="nav-link-item" style="color:#FFD24C;" href="${pageContext.request.contextPath}/admin/spotApplicationAdmin.jsp">
						<i class="fa-solid fa-shield-halved"></i> 관리자</a>
				</c:if>
			</c:if>
		</div>
	</div>
</div>

<c:if test="${sessionScope.locationOn == true}">
<script>
(function() {
    if (!navigator.geolocation) return;
    var csrfToken = '<%=util.CsrfUtil.getOrCreateToken(session)%>';
    var ctx = '${pageContext.request.contextPath}';

    function sendLocation() {
        navigator.geolocation.getCurrentPosition(function(pos) {
            var body = new URLSearchParams();
            body.append('latitude',  pos.coords.latitude);
            body.append('longitude', pos.coords.longitude);
            body.append('_csrf',     csrfToken);
            fetch(ctx + '/updateLocation', { method: 'POST', body: body });
        });
    }

    sendLocation();
    setInterval(sendLocation, 5 * 60 * 1000);

    // 페이지 이동/닫기 시 위치 공유 자동 OFF
    window.addEventListener('beforeunload', function() {
        var data = new URLSearchParams();
        data.append('_csrf', csrfToken);
        data.append('state', 'off');
        navigator.sendBeacon(ctx + '/toggleLocation',
            new Blob([data.toString()], { type: 'application/x-www-form-urlencoded' }));
    });
})();
</script>
</c:if>
