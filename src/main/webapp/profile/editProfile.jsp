<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dto.Profile" %>
<%@ page import="dao.ProfileRepository" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 프로필 수정</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <script src="../resources/js/customAlert.js"></script>
    <style>
        .profile-preview {
            width: 100px; height: 100px;
            object-fit: cover; border-radius: 50%;
            border: 3px solid #dee2e6;
        }
    </style>
</head>
<body>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
%>
<script>
    showAlert("로그인이 필요합니다.", function() {
        location.href = "../member/loginMember.jsp";
    });
</script>
<%
        return;
    }

    Profile profile = ProfileRepository.getProfileByUserId(userId);
    request.setAttribute("profile", profile);
    request.setAttribute("userId", userId);
    String csrfToken = util.CsrfUtil.getOrCreateToken(session);
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="p-4 mb-4 bg-body-tertiary rounded-3">
        <h1 class="display-5 fw-bold">프로필 수정</h1>
    </div>

    <div class="row justify-content-center">
        <div class="col-md-6">
            <form action="${pageContext.request.contextPath}/processUpdateProfile"
                  method="post" enctype="multipart/form-data">

                <!-- 현재 프로필 사진 미리보기 -->
                <div class="mb-4 text-center">
                    <c:choose>
                        <c:when test="${not empty profile.profileImage}">
                            <img src="${pageContext.request.contextPath}/resources/images/${profile.profileImage}"
                                 class="profile-preview mb-2" id="previewImg" alt="현재 프로필 사진">
                        </c:when>
                        <c:otherwise>
                            <div style="width:100px;height:100px;border-radius:50%;background:#e9ecef;
                                        display:flex;align-items:center;justify-content:center;
                                        font-size:40px;margin:0 auto 8px;"
                                 id="previewPlaceholder">👤</div>
                        </c:otherwise>
                    </c:choose>
                    <div>
                        <label class="form-label small text-muted">프로필 사진 변경</label>
                        <input type="file" name="profileImage" class="form-control form-control-sm"
                               accept="image/*" onchange="previewImage(this)">
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">닉네임</label>
                    <input type="text" name="nickname" class="form-control"
                           value="<c:out value="${not empty profile.nickname ? profile.nickname : ''}"/>"
                           placeholder="닉네임을 입력해주세요" maxlength="10">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">소개</label>
                    <textarea name="description" class="form-control" rows="4"
                              placeholder="자신을 소개해주세요"><c:out value="${not empty profile.description ? profile.description : ''}"/></textarea>
                </div>

                <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">저장</button>
                    <a href="${pageContext.request.contextPath}/profile/myProfile.jsp"
                       class="btn btn-secondary">취소</a>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>
</div>

<script>
    function previewImage(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = e => {
                let img = document.getElementById('previewImg');
                const placeholder = document.getElementById('previewPlaceholder');
                if (!img) {
                    img = document.createElement('img');
                    img.id = 'previewImg';
                    img.className = 'profile-preview mb-2';
                    if (placeholder) placeholder.replaceWith(img);
                }
                img.src = e.target.result;
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
</script>
</body>
</html>
