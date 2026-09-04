<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="dao.UserRepository, dao.SpotRepository, dto.User, dto.Spot" %>
<%@ page errorPage="../exceptionPages/exceptionNoSpot.jsp" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <title>상품 상세 정보</title>
</head>
<body>
<div class="container py-5">
    <jsp:include page="../common/menu.jsp"/>

    <div class="py-4">
        <h1 class="fw-bold" style="color:#1C1C1E;">장소정보</h1>
    </div>

    <%
        String userId = (String) session.getAttribute("userId");
        String spotIdString = request.getParameter("spotId");
        if (spotIdString == null || spotIdString.trim().isEmpty()) {
            response.sendRedirect("../spot/spots.jsp");
            return;
        }

        int spotId;
        try {
            spotId = Integer.parseInt(spotIdString);
        } catch (NumberFormatException e) {
            response.sendRedirect("../spot/spots.jsp");
            return;
        }

        String csrfToken = util.CsrfUtil.getOrCreateToken(session);
        Spot spot = SpotRepository.getSpotBySpotId(spotId);

        if (spot == null) {
            response.sendRedirect("../exceptionPages/exceptionNoSpot.jsp?spotId=" + spotId);
            return;
        }
    %>
    <div class="row align-items-md-stretch">
        <div class="col-md-8">
            <% if (spot.getSpotImage() != null && !spot.getSpotImage().isEmpty()) { %>
        <img src="<%=request.getContextPath()%>/resources/images/<%=util.HtmlUtil.escape(spot.getSpotImage())%>"
             style="width: 70%;" alt="스팟 이미지"/>
        <% } %>
            <h3>
                <b><%=util.HtmlUtil.escape(spot.getSpotName())%></b>
                <% if (spot.getActiveUserCount() > 0) { %>
                <span class="badge bg-success ms-2"><%=spot.getActiveUserCount()%>명 방문 중</span>
                <% } else { %>
                <span class="badge bg-secondary ms-2">방문자 없음</span>
                <% } %>
            </h3>
            <p><%=util.HtmlUtil.escape(spot.getSpotDescription())%>
            </p>
            <div class="d-flex gap-2 mt-3 flex-wrap">
                <a href="../review/reviews.jsp?spotId=<%=spot.getSpotId()%>" class="btn btn-primary">
                    리뷰 보기 &raquo;
                </a>
                <form action="${pageContext.request.contextPath}/processAddWishlist" method="post" style="display:inline;">
                    <input type="hidden" name="spotId" value="<%=spot.getSpotId()%>">
                    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                    <button type="submit" class="btn btn-warning">찜하기 &raquo;</button>
                </form>
                <a href="../spotApplication/spotRemoveApplication.jsp?spotId=<%=spot.getSpotId()%>" class="btn btn-outline-danger">
                    장소 삭제 요청
                </a>
            </div>
        </div>
    </div>

</div>
</body>

<jsp:include page="../common/footer.jsp"/>
</html>
