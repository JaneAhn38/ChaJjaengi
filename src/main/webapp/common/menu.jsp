<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
<link rel="stylesheet" href="../resources/css/theme.css" />
<script src="../resources/js/customAlert.js?v=2"></script>

<!-- 로고 + 메뉴 + 로그인 상태를 한 줄에 (index.jsp와 동일한 스타일) -->
<nav class="custom-nav d-flex justify-content-between align-items-center flex-wrap">
	<div class="nav-left">
		<a href="<c:url value="/index.jsp"/>" class="home-icon-box"><i class="fa-solid fa-house"></i></a>
		<a href="<c:url value="/index.jsp"/>" class="nav-home-text">차쟁이</a>
		<c:if test="${sessionScope.userRole == 'ADMIN'}">
			<a href="${pageContext.request.contextPath}/admin/spotApplicationAdmin.jsp" style="color:#FFD24C; font-weight:700; text-decoration:none;">
				<i class="fa-solid fa-shield-halved"></i> 관리자 모드</a>
		</c:if>
	</div>

	<div class="nav-right">
		<a class="nav-link-item" href="<c:url value="/spot/spots.jsp"/>">
			<i class="fa-solid fa-location-dot"></i> 스팟 보기</a>
		<a class="nav-link-item" href="${pageContext.request.contextPath}/community/board.jsp">
			<i class="fa-solid fa-comments"></i> 커뮤니티</a>
		<c:choose>
			<c:when test="${empty sessionScope.userId}">
				<c:if test="${empty hideLoginLink}">
					<a class="nav-link-item" href="<c:url value="/member/loginMember.jsp"/>">
						<i class="fa-solid fa-right-to-bracket"></i> 로그인</a>
				</c:if>
				<a class="nav-signup-btn" href="<c:url value="/member/addMember.jsp"/>">
					<i class="fa-solid fa-user-plus"></i> 회원가입</a>
			</c:when>
			<c:otherwise>
				<c:if test="${sessionScope.userRole != 'ADMIN'}">
					<div class="mypage-dropdown" tabindex="0">
						<span class="mypage-dropdown-toggle">
							<i class="fa-solid fa-user"></i> 마이페이지 <i class="fa-solid fa-chevron-down" style="font-size:0.7em;"></i>
						</span>
						<div class="mypage-dropdown-menu">
							<a href="${pageContext.request.contextPath}/profile/myProfile.jsp">
								<i class="fa-solid fa-user"></i> 내 프로필</a>
							<a href="<c:url value="/member/updateMember.jsp"/>">
								<i class="fa-solid fa-pen-to-square"></i> 개인정보 수정</a>
							<a href="${pageContext.request.contextPath}/spotApplication/myApplications.jsp">
								<i class="fa-solid fa-clipboard-list"></i> 나의 신청 내역</a>
							<a href="${pageContext.request.contextPath}/wishlist/wishlist.jsp">
								<i class="fa-solid fa-heart"></i> 찜목록</a>
						</div>
					</div>
				</c:if>

				<span class="nav-user-badge">[<c:out value="${sessionScope.userId}"/>님]</span>
				<form action="${pageContext.request.contextPath}/processLogoutMember" method="post" class="d-inline m-0 p-0">
					<input type="hidden" name="_csrf" value="<%=util.CsrfUtil.getOrCreateToken(session)%>">
					<button type="submit" class="nav-link-item nav-logout-btn">
						로그아웃 <i class="fa-solid fa-right-from-bracket"></i>
					</button>
				</form>
			</c:otherwise>
		</c:choose>
	</div>
</nav>

<c:if test="${sessionScope.locationOn == true}">
<script>
(function() {
    if (!navigator.geolocation) return;
    var csrfToken = '<%=util.CsrfUtil.getOrCreateToken(session)%>';
    var ctx = '${pageContext.request.contextPath}';

    function sendLocation() {
        navigator.geolocation.getCurrentPosition(
            function(pos) {
                var body = new URLSearchParams();
                body.append('latitude',  pos.coords.latitude);
                body.append('longitude', pos.coords.longitude);
                body.append('_csrf',     csrfToken);
                fetch(ctx + '/updateLocation', { method: 'POST', body: body });
            },
            function(err) {
                console.warn('위치 정보를 가져오지 못했습니다:', err.message);
            }
        );
    }

    sendLocation();
    setInterval(sendLocation, 5 * 60 * 1000);
    // 페이지 이동할 때마다 위치공유를 꺼버리면 사이트 내에서 다른 페이지로만
    // 이동해도 계속 꺼져버리는 문제가 있어 제거함. 탭/브라우저를 닫아서 더 이상
    // 위치가 갱신되지 않으면, 집계 쪽(PresenceAggregator)에서 10분 지난 위치는
    // 알아서 인원수에서 빠지므로 별도의 종료 신호가 없어도 자연히 처리됨.
})();
</script>
</c:if>
