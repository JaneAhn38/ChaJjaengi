<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostRepository" %>
<%@ page import="dto.Post" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>커뮤니티</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
</head>
<body>
<div class="container py-4">
    <jsp:include page="../common/menu.jsp"/>

    <%
        String category = request.getParameter("category");
        String keyword  = request.getParameter("keyword");
        if (category == null) category = "ALL";
        if (keyword  == null) keyword  = "";
        // category 화이트리스트 검증
        java.util.Set<String> validCategories = new java.util.HashSet<>(
            java.util.Arrays.asList("ALL", "FREE", "REVIEW", "QUESTION", "RECOMMEND"));
        if (!validCategories.contains(category)) category = "ALL";

        String pageStr = request.getParameter("page");
        int currentPage = 1;
        try { currentPage = Integer.parseInt(pageStr); } catch (Exception ignored) {}

        List<Post> posts      = PostRepository.getPosts(category, currentPage, keyword.isEmpty() ? null : keyword);
        int total             = PostRepository.getTotalCount(category, keyword.isEmpty() ? null : keyword);
        int totalPages        = (int) Math.ceil((double) total / 10);
    %>

    <div class="p-4 mb-3 bg-body-tertiary rounded-3">
        <h2 class="fw-bold">커뮤니티</h2>
    </div>

    <!-- 카테고리 탭 -->
    <ul class="nav nav-tabs mb-3">
        <li class="nav-item"><a class="nav-link <%= "ALL".equals(category) ? "active" : "" %>" href="board.jsp?category=ALL">전체</a></li>
        <li class="nav-item"><a class="nav-link <%= "FREE".equals(category) ? "active" : "" %>" href="board.jsp?category=FREE">자유</a></li>
        <li class="nav-item"><a class="nav-link <%= "REVIEW".equals(category) ? "active" : "" %>" href="board.jsp?category=REVIEW">드라이브 후기</a></li>
        <li class="nav-item"><a class="nav-link <%= "QUESTION".equals(category) ? "active" : "" %>" href="board.jsp?category=QUESTION">질문</a></li>
        <li class="nav-item"><a class="nav-link <%= "RECOMMEND".equals(category) ? "active" : "" %>" href="board.jsp?category=RECOMMEND">추천</a></li>
    </ul>

    <!-- 검색 폼 + 글쓰기 버튼 -->
    <div class="mb-3" style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:nowrap;">
        <form method="get" action="board.jsp" style="display:flex; align-items:center; gap:8px; flex:1; min-width:0;">
            <input type="hidden" name="category" value="<%= category %>">
            <input type="text" name="keyword" class="form-control" style="flex:1; min-width:0;" placeholder="제목 또는 내용으로 검색" value="<%= util.HtmlUtil.escape(keyword) %>">
            <button type="submit" class="btn btn-outline-secondary" style="flex-shrink:0;">검색</button>
            <% if (!keyword.isEmpty()) { %>
            <a href="board.jsp?category=<%= category %>" class="btn btn-outline-danger" style="flex-shrink:0;">초기화</a>
            <% } %>
        </form>
        <% if (session.getAttribute("userId") != null) { %>
        <a href="addPost.jsp" class="btn btn-primary btn-sm" style="flex-shrink:0;">글쓰기</a>
        <% } %>
    </div>

    <!-- 검색 결과 수 -->
    <% if (!keyword.isEmpty()) { %>
    <p class="text-muted small mb-2">"<%= util.HtmlUtil.escape(keyword) %>" 검색 결과 <%= total %>건</p>
    <% } %>

    <!-- 게시글 목록 -->
    <table class="table table-hover align-middle">
        <thead class="table-light">
        <tr>
            <th style="width:80px">카테고리</th>
            <th>제목</th>
            <th style="width:100px">작성자</th>
            <th style="width:70px">좋아요</th>
            <th style="width:70px">댓글</th>
            <th style="width:70px">조회</th>
            <th style="width:110px">작성일</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (posts.isEmpty()) {
        %>
        <tr><td colspan="7" class="text-center text-muted py-4">게시글이 없습니다.</td></tr>
        <%
            } else {
                for (Post p : posts) {
                    String dateStr = p.getCreatedAt() != null
                            ? p.getCreatedAt().toLocalDate().toString() : "";
        %>
        <tr>
            <td><span class="badge bg-secondary"><%= p.getCategoryLabel() %></span></td>
            <td style="cursor:pointer;" onclick="location.href='post.jsp?postId=<%= p.getPostId() %>'">
                <%= util.HtmlUtil.escape(p.getTitle()) %>
            </td>
            <td>
                <a href="<%= request.getContextPath() %>/profile/userProfile.jsp?userId=<%= p.getUserId() %>"
                   class="text-decoration-none text-dark"><%= util.HtmlUtil.escape(p.getAuthorName()) %></a>
            </td>
            <td>♥ <%= p.getLikeCount() %></td>
            <td>💬 <%= p.getCommentCount() %></td>
            <td><%= p.getViewCount() %></td>
            <td><small><%= dateStr %></small></td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <!-- 페이지네이션 -->
    <% if (totalPages > 1) { %>
    <nav>
        <ul class="pagination justify-content-center">
            <% for (int i = 1; i <= totalPages; i++) { %>
            <li class="page-item <%= i == currentPage ? "active" : "" %>">
                <a class="page-link" href="board.jsp?category=<%= category %>&keyword=<%= util.HtmlUtil.escape(keyword) %>&page=<%= i %>"><%= i %></a>
            </li>
            <% } %>
        </ul>
    </nav>
    <% } %>

    <jsp:include page="../common/footer.jsp"/>
</div>
</body>
</html>
