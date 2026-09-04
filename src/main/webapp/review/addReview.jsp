<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 장소 리뷰 작성</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css" />
    <link rel="stylesheet" href="../resources/css/theme.css" />
    <script src="../resources/js/customAlert.js"></script>
    <script type="text/javascript" src="../resources/js/validationReviewSpot.js"></script>
</head>
<body>
<%

    String userId = (String) session.getAttribute("userId");
    String spotId = request.getParameter("spotId");
    String csrfToken = util.CsrfUtil.getOrCreateToken(session);
    if (userId == null) {
%>

<script>
    showAlert("로그인을 해야 리뷰를 작성할 수 있습니다!", function() {
        location.href = "../member/loginMember.jsp";
    });
</script>
<%
        return;
    }
%>
<fmt:setLocale value="ko" />
<fmt:bundle basename="bundle.message">
    <div class="container py-4">
        <%@ include file="../common/menu.jsp"%>

        <div class="p-5 mb-4 bg-body-tertiary rounded-3">
            <div class="container-fluid py-5">
                <h1 class="display-5 fw-bold">
                    <fmt:message key="writeReview" />
                </h1>
                <p class="col-md-8 fs-4">장소에 대한 리뷰를 작성해주세요.</p>
            </div>
        </div>

        <div class="row align-items-md-stretch">
            <div class="text-end mb-3">
                <a href="?language=ko">Korean</a> | <a href="?language=en">English</a>
                <a href="../member/logoutMember.jsp" class="btn btn-sm btn-success ms-3">logout</a>
            </div>

            <!-- 리뷰 작성 폼 -->
            <form name="newReview" action="${pageContext.request.contextPath}/processAddReview" method="post" class="form-horizontal" onsubmit="return validateReviewForm()">


                <input type="hidden" name="spotId" value="<%= util.HtmlUtil.escape(spotId) %>" />
                <input type="hidden" name="userId" value="<%= util.HtmlUtil.escape(userId) %>" />

                <div class="mb-3 row">
                    <label class="col-sm-2 col-form-label">별점</label>
                    <div class="col-sm-3">
                        <select name="rating" class="form-select">
                            <option value="5">★★★★★</option>
                            <option value="4">★★★★</option>
                            <option value="3">★★★</option>
                            <option value="2">★★</option>
                            <option value="1">★</option>
                        </select>
                    </div>
                </div>

                <div class="mb-3 row">
                    <label class="col-sm-2 col-form-label">리뷰 내용</label>
                    <div class="col-sm-5">
                     <textarea name="content" rows="5" class="form-control"
                               placeholder="솔직한 후기를 남겨주세요"></textarea>
                    </div>
                </div>

                <div class="mb-3 row">
                    <div class="offset-sm-2 col-sm-10">
                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                        <input type="submit" class="btn btn-primary" value="리뷰 등록">
                    </div>
                </div>

            </form>
        </div>

        <%@ include file="../common/footer.jsp"%>
    </div>
</fmt:bundle>
</body>
</html>
