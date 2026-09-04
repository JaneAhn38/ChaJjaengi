<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.SpotRepository" %>
<%@ page import="dto.Spot" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 장소 삭제 신청</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <script src="../resources/js/customAlert.js"></script>
</head>
<body>
<%
    String userId = (String) session.getAttribute("userId");
    String csrfToken = util.CsrfUtil.getOrCreateToken(session);
    if (userId == null) {
%>
<script>
    showAlert("로그인을 해야 장소 삭제 신청을 할 수 있습니다!", function() {
        location.href = "../member/loginMember.jsp";
    });
</script>
<%
        return;
    }

    String spotIdStr = request.getParameter("spotId");
    if (spotIdStr == null || spotIdStr.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/spot/spots.jsp");
        return;
    }

    int spotId;
    try {
        spotId = Integer.parseInt(spotIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/spot/spots.jsp");
        return;
    }
    Spot spot = SpotRepository.getSpotBySpotId(spotId);
    if (spot == null) {
        response.sendRedirect(request.getContextPath() + "/exceptionPages/exceptionNoSpot.jsp");
        return;
    }
%>
<fmt:setLocale value="ko"/>
<fmt:bundle basename="bundle.message">
    <div class="container py-4">
        <%@ include file="../common/menu.jsp" %>

        <div class="p-5 mb-4 bg-body-tertiary rounded-3">
            <div class="container-fluid py-5">
                <h1 class="display-5 fw-bold">장소 삭제 신청</h1>
                <p class="col-md-8 fs-4">Spot Remove Application</p>
            </div>
        </div>

        <div class="row align-items-md-stretch">
            <form name="removeApplicationForm"
                  action="${pageContext.request.contextPath}/processRemoveSpot"
                  method="post"
                  class="form-horizontal">

                <div class="mb-3 row">
                    <label class="col-sm-2 col-form-label fw-bold">삭제 신청 장소</label>
                    <div class="col-sm-6">
                        <input type="text" class="form-control" value="<%= spot.getSpotName() %>" readonly>
                        <input type="hidden" name="spotId" value="<%= spotId %>">
                    </div>
                </div>

                <div class="mb-3 row">
                    <label class="col-sm-2 col-form-label">삭제 사유</label>
                    <div class="col-sm-6">
                        <textarea name="remove_reason" id="remove_reason" rows="4"
                                  class="form-control"
                                  placeholder="삭제 사유를 10자 이상 입력해주세요"
                                  required minlength="10"></textarea>
                    </div>
                </div>

                <div class="mb-3 row">
                    <div class="col-sm-offset-2 col-sm-10">
                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                        <button type="submit" class="btn btn-danger"
                                onclick="return confirm('정말로 이 장소 삭제를 신청하시겠습니까?')">
                            삭제 신청
                        </button>
                        <a href="${pageContext.request.contextPath}/spot/spot.jsp?spotId=<%= spotId %>"
                           class="btn btn-secondary ms-2">취소</a>
                    </div>
                </div>
            </form>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>
</fmt:bundle>
</body>
</html>
