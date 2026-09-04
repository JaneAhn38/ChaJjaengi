<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.WishlistRepository" %>
<%@ page import="dto.Spot" %>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
<link rel="stylesheet" href="../resources/css/theme.css" />
<script src="../resources/js/customAlert.js"></script>
<meta charset="UTF-8">
<title>Wishlist</title>
</head>
<body>
<%
    String userId = (String) session.getAttribute("userId");
    String csrfToken = util.CsrfUtil.getOrCreateToken(session);
    if (userId == null) {
%>
<script>
    showAlert("로그인을 해야 찜 목록을 볼 수 있습니다!", function() {
        location.href = "../member/loginMember.jsp";
    });
</script>
<%
        return;
    }

    List<Spot> wishlistSpots = WishlistRepository.getWishlistSpots(userId);
%>

<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="p-5 mb-4 bg-body-tertiary rounded-3">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold">찜 목록</h1>
            <p class="col-md-8 fs-4">WishList</p>
        </div>
    </div>

    <% if ("duplicate".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning alert-dismissible">이미 찜한 장소입니다.</div>
    <% } %>

    <div class="row align-items-md-stretch text-center">
    <% if (wishlistSpots.isEmpty()) { %>
    <div class="alert alert-secondary">찜한 장소가 없습니다.</div>
    <% } %>
    <% for (Spot spot : wishlistSpots) { %>
    <div class="col-md-4">
        <div class="h-100 p-2">
            <img src="<%= request.getContextPath() %>/resources/images/<%= util.HtmlUtil.escape(spot.getSpotImage()) %>" width="100">
            <p><%= util.HtmlUtil.escape(spot.getSpotName()) %></p>
            <form action="<%= request.getContextPath() %>/processRemoveWishlist" method="post">
                <input type="hidden" name="spotId" value="<%= spot.getSpotId() %>">
                <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                <button type="submit" class="btn btn-danger">찜 삭제</button>
            </form>
        </div>
    </div>
    <% } %>
    </div>

    <div class="row align-items-md-stretch text-center">
        <p><a href="../spot/spots.jsp" class="btn btn-secondary" role="button">장소 보러가기 &raquo;</a></p>
    </div>
    <%@ include file="../common/footer.jsp" %>
</div>
</body>
</html>
