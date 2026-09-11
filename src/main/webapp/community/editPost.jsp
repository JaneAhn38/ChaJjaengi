<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostRepository" %>
<%@ page import="dto.Post, dto.PostImage" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 수정</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
</head>
<body>
<div class="container py-4">
    <jsp:include page="../common/menu.jsp"/>

    <%
        String loginUserId = (String) session.getAttribute("userId");
        if (loginUserId == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
            return;
        }

        String postIdStr = request.getParameter("postId");
        int postId = 0;
        try { postId = Integer.parseInt(postIdStr); } catch (Exception ignored) {}

        Post post = PostRepository.getPostById(postId);
        if (post == null || !loginUserId.equals(post.getUserId())) {
            response.sendRedirect(request.getContextPath() + "/community/board.jsp");
            return;
        }
        String csrfToken = util.CsrfUtil.getOrCreateToken(session);
    %>

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <h4 class="mb-4">게시글 수정</h4>

            <% if ("empty".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">제목과 내용을 입력해주세요.</div>
            <% } %>

            <form action="<%= request.getContextPath() %>/processUpdatePost" method="post" enctype="multipart/form-data">
                <input type="hidden" name="postId" value="<%= postId %>">

                <!-- 카테고리 -->
                <div class="mb-3">
                    <label class="form-label fw-bold">카테고리</label>
                    <div class="d-flex gap-3">
                        <%
                            String[] catValues = {"FREE", "REVIEW", "QUESTION", "RECOMMEND"};
                            String[] catLabels = {"자유", "드라이브 후기", "질문", "추천"};
                            for (int i = 0; i < catValues.length; i++) {
                                boolean selected = catValues[i].equals(post.getCategory());
                        %>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="category"
                                   value="<%= catValues[i] %>" id="cat<%= catValues[i] %>"
                                   <%= selected ? "checked" : "" %>>
                            <label class="form-check-label" for="cat<%= catValues[i] %>"><%= catLabels[i] %></label>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- 제목 -->
                <div class="mb-3">
                    <label for="title" class="form-label fw-bold">제목</label>
                    <input type="text" class="form-control" id="title" name="title"
                           maxlength="100" value="<%= util.HtmlUtil.escape(post.getTitle()) %>" required>
                </div>

                <!-- 내용 -->
                <div class="mb-3">
                    <label for="content" class="form-label fw-bold">내용</label>
                    <textarea class="form-control" id="content" name="content"
                              rows="12" required><%= util.HtmlUtil.escape(post.getContent()) %></textarea>
                </div>

                <!-- 기존 이미지 -->
                <% if (!post.getImages().isEmpty()) { %>
                <div class="mb-3">
                    <label class="form-label fw-bold">기존 이미지 <small class="text-muted fw-normal">(삭제할 이미지 선택)</small></label>
                    <div class="d-flex flex-wrap gap-3">
                        <% for (PostImage img : post.getImages()) { %>
                        <div class="text-center">
                            <img src="<%= img.getImagePath() %>"
                                 style="height:100px; border-radius:4px; border:1px solid #ddd;">
                            <div class="form-check mt-1">
                                <input class="form-check-input" type="checkbox"
                                       name="deleteImageIds" value="<%= img.getImageId() %>"
                                       id="del<%= img.getImageId() %>">
                                <label class="form-check-label text-danger small" for="del<%= img.getImageId() %>">삭제</label>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <!-- 새 이미지 추가 -->
                <div class="mb-4">
                    <label for="postImages" class="form-label fw-bold">이미지 추가 <small class="text-muted fw-normal">(jpg, jpeg, png, gif, webp / 최대 5MB)</small></label>
                    <input type="file" class="form-control" id="postImages" name="postImages"
                           multiple accept="image/jpeg,image/png,image/gif,image/webp">
                    <div id="previewArea" class="d-flex flex-wrap gap-2 mt-2"></div>
                </div>

                <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">저장</button>
                    <a href="post.jsp?postId=<%= postId %>" class="btn btn-secondary">취소</a>
                </div>
            </form>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp"/>
</div>
<script>
document.getElementById('postImages').addEventListener('change', function () {
    const preview = document.getElementById('previewArea');
    preview.innerHTML = '';
    for (const file of this.files) {
        const reader = new FileReader();
        reader.onload = e => {
            const img = document.createElement('img');
            img.src = e.target.result;
            img.style.cssText = 'height:100px; border-radius:4px; border:1px solid #ddd;';
            preview.appendChild(img);
        };
        reader.readAsDataURL(file);
    }
});
</script>
</body>
</html>
