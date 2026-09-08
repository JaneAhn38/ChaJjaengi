<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dto.Review" %>
<%@ page import="dao.ReviewRepository" %>
<%@ page import="dto.Spot" %>
<%@ page import="dao.SpotRepository" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 리뷰</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
</head>
<body>
<%
    String loginUserId = (String) session.getAttribute("userId");
    String csrfToken   = util.CsrfUtil.getOrCreateToken(session);

    String spotIdStr = request.getParameter("spotId");
    int spotId = 0;
    try { spotId = Integer.parseInt(spotIdStr); } catch (Exception ignored) {}

    ArrayList<Review> reviewList = ReviewRepository.getReviewsBySpotId(spotId);
    double avgRating = ReviewRepository.getAverageRatingBySpotId(spotId);
    boolean alreadyReviewed = loginUserId != null && ReviewRepository.hasReviewed(loginUserId, spotId);

    request.setAttribute("reviewList", reviewList);
%>
<fmt:setLocale value="${empty param.language ? 'ko' : param.language}"/>
<fmt:bundle basename="bundle.message">
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="p-5 mb-4 bg-body-tertiary rounded-3">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold"><fmt:message key="reviewListTitle"/></h1>
            <p class="col-md-8 fs-4"><fmt:message key="reviewListSubtitle"/></p>
        </div>
    </div>

    <!-- 중복 작성 알림 -->
    <% if ("duplicate".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning">이미 이 장소에 리뷰를 작성했습니다.</div>
    <% } %>

    <!-- 평균 별점 -->
    <% if (avgRating > 0) { %>
    <div class="mb-3">
        <strong>평균 별점:</strong>
        <span class="text-warning"><%= String.format("%.1f", avgRating) %> / 5.0</span>
    </div>
    <% } %>

    <!-- 리뷰 목록 -->
    <% if (reviewList.isEmpty()) { %>
    <div class="alert alert-secondary">아직 작성된 리뷰가 없습니다.</div>
    <% } %>

    <% for (Review review : reviewList) {
        boolean isMine = loginUserId != null && loginUserId.equals(review.getUserId());
        String dateStr = review.getReviewCreatedAt() != null
                ? review.getReviewCreatedAt().toLocalDate().toString() : "";
        int stars = (int) review.getReviewRating();
    %>
    <div class="card mb-3">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-start">
                <div>
                    <span class="text-warning">
                        <% for (int i = 0; i < stars; i++) { %>⭐<% } %>
                    </span>
                    <span class="fw-bold ms-2"><%= util.HtmlUtil.escape(review.getAuthorName()) %></span>
                    <small class="text-muted ms-2"><%= dateStr %></small>
                </div>
                <% if (isMine) { %>
                <form action="<%= request.getContextPath() %>/processDeleteReview" method="post"
                      onsubmit="return confirm('리뷰를 삭제하시겠습니까?')">
                    <input type="hidden" name="reviewId" value="<%= review.getReviewId() %>">
                    <input type="hidden" name="spotId"   value="<%= spotId %>">
                    <input type="hidden" name="_csrf"    value="<%= csrfToken %>">
                    <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
                </form>
                <% } %>
            </div>
            <p class="card-text mt-2" style="white-space:pre-wrap;"><%= util.HtmlUtil.escape(review.getReviewText()) %></p>
        </div>
    </div>
    <% } %>

    <!-- 리뷰 작성 버튼 -->
    <div class="text-end mt-3">
        <% if (loginUserId == null) { %>
        <a href="<%= request.getContextPath() %>/member/loginMember.jsp" class="btn btn-primary">
            로그인 후 리뷰 작성
        </a>
        <% } else if (alreadyReviewed) { %>
        <button class="btn btn-secondary" disabled>이미 리뷰를 작성했습니다</button>
        <% } else { %>
        <a href="addReview.jsp?spotId=<%= spotId %>" class="btn btn-primary">
            <fmt:message key="writeReview"/>
        </a>
        <% } %>
    </div>

    <%@ include file="../common/footer.jsp" %>
</div>
</fmt:bundle>
</body>
</html>
