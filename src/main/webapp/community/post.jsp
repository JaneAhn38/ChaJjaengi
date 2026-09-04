<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostRepository, dao.PostCommentRepository, dao.PostLikeRepository" %>
<%@ page import="dto.Post, dto.PostComment, dto.PostImage" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
</head>
<body>
<div class="container py-4">
    <jsp:include page="../common/menu.jsp"/>

    <%
        String postIdStr = request.getParameter("postId");
        int postId = 0;
        try { postId = Integer.parseInt(postIdStr); } catch (Exception ignored) {}

        Post post = PostRepository.getPostById(postId);
        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/community/board.jsp");
            return;
        }

        PostRepository.incrementViewCount(postId);

        String loginUserId = (String) session.getAttribute("userId");
        boolean isAuthor   = loginUserId != null && loginUserId.equals(post.getUserId());
        boolean liked      = loginUserId != null && PostLikeRepository.isLiked(postId, loginUserId);

        List<PostComment> comments = PostCommentRepository.getCommentsByPostId(postId);
        String dateStr = post.getCreatedAt() != null ? post.getCreatedAt().toString().replace("T", " ").substring(0, 16) : "";
        String csrfToken = util.CsrfUtil.getOrCreateToken(session);
    %>

    <!-- 알림 메시지 -->
    <% if ("true".equals(request.getParameter("reported"))) { %>
    <div class="alert alert-success alert-dismissible fade show">신고가 접수되었습니다. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    <% } else if ("already_reported".equals(request.getParameter("error"))) { %>
    <div class="alert alert-warning alert-dismissible fade show">이미 신고한 게시글입니다. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
    <% } %>

    <!-- 게시글 카드 -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div>
                <span class="badge bg-secondary me-2"><%= post.getCategoryLabel() %></span>
                <span class="fs-5 fw-bold"><%= util.HtmlUtil.escape(post.getTitle()) %></span>
            </div>
            <% if (isAuthor) { %>
            <div>
                <a href="editPost.jsp?postId=<%= postId %>" class="btn btn-sm btn-outline-secondary me-1">수정</a>
                <form action="<%= request.getContextPath() %>/processRemovePost" method="post" style="display:inline;"
                      onsubmit="return confirm('게시글을 삭제하시겠습니까?')">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                    <button type="submit" class="btn btn-sm btn-outline-danger">삭제</button>
                </form>
            </div>
            <% } %>
        </div>
        <div class="card-body">
            <div class="d-flex text-muted small mb-3">
                <span class="me-3">작성자: <strong><%= util.HtmlUtil.escape(post.getAuthorName()) %></strong></span>
                <span class="me-3">작성일: <%= dateStr %></span>
                <span>조회 <%= post.getViewCount() %></span>
            </div>

            <!-- 본문 -->
            <div style="white-space:pre-wrap; line-height:1.7;"><%= util.HtmlUtil.escape(post.getContent()) %></div>

            <!-- 첨부 이미지 -->
            <% if (!post.getImages().isEmpty()) { %>
            <div class="mt-3 d-flex flex-wrap gap-2">
                <% for (PostImage img : post.getImages()) { %>
                <img src="<%= request.getContextPath() %>/resources/images/<%= img.getImagePath() %>"
                     class="img-thumbnail" style="max-height:250px; cursor:pointer;"
                     onclick="window.open(this.src)">
                <% } %>
            </div>
            <% } %>

            <!-- 좋아요 -->
            <div class="mt-4 d-flex align-items-center gap-3">
                <button id="likeBtn"
                        class="btn <%= liked ? "btn-danger" : "btn-outline-danger" %>"
                        onclick="toggleLike(<%= postId %>)"
                        <%= loginUserId == null ? "disabled title='로그인 후 이용 가능'" : "" %>>
                    ♥ <span id="likeCount"><%= post.getLikeCount() %></span>
                </button>

                <!-- 신고 버튼 (비로그인·작성자 제외) -->
                <% if (loginUserId != null && !isAuthor) { %>
                <button class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#reportModal">신고</button>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 댓글 목록 -->
    <div id="comments">
        <h5 class="mb-3">댓글 <span class="badge bg-primary"><%= comments.size() %></span></h5>

        <% for (PostComment c : comments) {
            String cDate = c.getCreatedAt() != null ? c.getCreatedAt().toString().replace("T"," ").substring(0,16) : "";
            boolean isMine = loginUserId != null && loginUserId.equals(c.getUserId());
        %>
        <div class="card mb-2">
            <div class="card-body py-2">
                <div class="d-flex justify-content-between">
                    <span class="fw-bold small"><%= util.HtmlUtil.escape(c.getAuthorName()) %></span>
                    <span class="text-muted small"><%= cDate %></span>
                </div>
                <p class="mb-1 mt-1" style="white-space:pre-wrap;"><%= util.HtmlUtil.escape(c.getContent()) %></p>
                <% if (isMine) { %>
                <form action="<%= request.getContextPath() %>/processRemoveComment" method="post" style="display:inline;">
                    <input type="hidden" name="commentId" value="<%= c.getCommentId() %>">
                    <input type="hidden" name="postId"    value="<%= postId %>">
                    <input type="hidden" name="_csrf"      value="<%= csrfToken %>">
                    <button type="submit" class="btn btn-link btn-sm text-danger p-0">삭제</button>
                </form>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- 댓글 작성 -->
        <% if (loginUserId != null) { %>
        <form action="<%= request.getContextPath() %>/processAddComment" method="post" class="mt-3">
            <input type="hidden" name="postId" value="<%= postId %>">
            <input type="hidden" name="_csrf"  value="<%= csrfToken %>">
            <div class="input-group">
                <textarea name="content" class="form-control" rows="2" placeholder="댓글을 입력하세요" required></textarea>
                <button type="submit" class="btn btn-primary">등록</button>
            </div>
        </form>
        <% } else { %>
        <p class="text-muted mt-3"><a href="<%= request.getContextPath() %>/member/loginMember.jsp">로그인</a>하면 댓글을 작성할 수 있습니다.</p>
        <% } %>
    </div>

    <div class="mt-3">
        <a href="board.jsp" class="btn btn-secondary btn-sm">목록으로</a>
    </div>

    <!-- 신고 모달 -->
    <div class="modal fade" id="reportModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="<%= request.getContextPath() %>/processReportPost" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="_csrf"  value="<%= csrfToken %>">
                    <div class="modal-header">
                        <h5 class="modal-title">게시글 신고</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label">신고 사유</label>
                        <textarea name="reason" class="form-control" rows="3"
                                  placeholder="신고 사유를 입력하세요" required></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                        <button type="submit" class="btn btn-danger">신고</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp"/>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function toggleLike(postId) {
    fetch('<%= request.getContextPath() %>/processToggleLike', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'postId=' + postId + '&_csrf=<%= csrfToken %>'
    })
    .then(res => res.json())
    .then(data => {
        if (data.error === 'login_required') {
            showAlert('로그인 후 이용할 수 있습니다.');
            return;
        }
        document.getElementById('likeCount').textContent = data.likeCount;
        const btn = document.getElementById('likeBtn');
        btn.className = data.liked
            ? 'btn btn-danger'
            : 'btn btn-outline-danger';
    });
}
</script>
</body>
</html>
