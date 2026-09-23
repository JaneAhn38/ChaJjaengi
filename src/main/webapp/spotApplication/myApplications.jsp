<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="dto.AddSpotApplication" %>
<%@ page import="dao.AddSpotApplicationRepository" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 나의 신청 내역</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <script src="../resources/js/customAlert.js?v=2"></script>
    <style>
        .badge-PENDING  { background-color: #ffc107; color: #000; }
        .badge-APPROVED { background-color: #198754; color: #fff; }
        .badge-REJECTED { background-color: #dc3545; color: #fff; }
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

    ArrayList<AddSpotApplication> addList = AddSpotApplicationRepository.getAddApplicationByUserId(userId);
    request.setAttribute("addList", addList);
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="py-4">
        <h1 class="fw-bold" style="color:#1C1C1E;">나의 신청 내역</h1>
        <p class="fs-5" style="color:var(--figma-text-gray);">장소 추가 신청 현황을 확인할 수 있습니다.</p>
    </div>

    <div id="addTab">
        <c:choose>
            <c:when test="${empty addList}">
                <div class="alert alert-secondary">장소 추가 신청 내역이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                    <tr>
                        <th>장소명</th>
                        <th>카테고리</th>
                        <th>설명</th>
                        <th>신청일</th>
                        <th>상태</th>
                        <th>거절 사유</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="app" items="${addList}">
                        <tr>
                            <td><c:out value="${app.spotName}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${app.spotCategory == '1'}">카페/음식점</c:when>
                                    <c:when test="${app.spotCategory == '2'}">공원/자연</c:when>
                                    <c:when test="${app.spotCategory == '3'}">쇼핑</c:when>
                                    <c:when test="${app.spotCategory == '4'}">관광/랜드마크</c:when>
                                    <c:when test="${app.spotCategory == '5'}">문화/공연</c:when>
                                    <c:otherwise>${app.spotCategory}</c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${app.spotDescription}"/></td>
                            <td>${app.createdAt}</td>
                            <td>
                                <span class="badge badge-${app.status}">
                                    <c:choose>
                                        <c:when test="${app.status == 'PENDING'}">검토 중</c:when>
                                        <c:when test="${app.status == 'APPROVED'}">승인됨</c:when>
                                        <c:when test="${app.status == 'REJECTED'}">거절됨</c:when>
                                        <c:otherwise>${app.status}</c:otherwise>
                                    </c:choose>
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${app.status == 'REJECTED' and not empty app.rejectReason}">
                                        <span class="text-danger small"><c:out value="${app.rejectReason}"/></span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted small">-</span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>

    <%@ include file="../common/footer.jsp" %>
</div>
</body>
</html>
