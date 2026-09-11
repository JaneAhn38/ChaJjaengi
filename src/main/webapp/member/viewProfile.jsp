<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dto.Profile" %>
<%@ page import="dto.Car" %>
<%@ page import="dao.ProfileRepository" %>
<%@ page import="dao.CarRepository" %>
<%@ page import="dao.UserRepository" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 프로필</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <script src="../resources/js/customAlert.js?v=2"></script>
    <style>
        .profile-img {
            width: 120px; height: 120px;
            object-fit: cover; border-radius: 50%;
            border: 3px solid #dee2e6;
        }
        .profile-img-placeholder {
            width: 120px; height: 120px;
            border-radius: 50%; background: #e9ecef;
            display: flex; align-items: center; justify-content: center;
            font-size: 48px; border: 3px solid #dee2e6;
        }
        .car-img {
            width: 100%; height: 160px;
            object-fit: cover; border-radius: 8px;
        }
        .car-img-placeholder {
            width: 100%; height: 160px;
            background: #e9ecef; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 40px;
        }
    </style>
</head>
<body>
<%
    String myUserId = (String) session.getAttribute("userId");
    if (myUserId == null) {
%>
<script>
    showAlert("로그인이 필요합니다.", function() {
        location.href = "../member/loginMember.jsp";
    });
</script>
<%
        return;
    }

    String targetUserId = request.getParameter("userId");
    if (targetUserId == null || targetUserId.isBlank()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // 본인 프로필이면 마이페이지로
    if (targetUserId.equals(myUserId)) {
        response.sendRedirect(request.getContextPath() + "/profile/myProfile.jsp");
        return;
    }

    // 방문 멤버 목록에서 넘어온 게 아니라 URL을 직접 조작해 들어온 경우까지 막기 위해,
    // 대상 유저가 실제로 "프로필 공개"에 동의했는지 서버에서 다시 한 번 확인
    if (!UserRepository.isProfileShared(targetUserId)) {
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>
    <div class="alert alert-secondary mt-4">비공개 프로필이거나 존재하지 않는 사용자입니다.</div>
</div>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
        return;
    }

    Profile profile = ProfileRepository.getProfileByUserId(targetUserId);
    ArrayList<Car> cars = CarRepository.getCarsByUserId(targetUserId);
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="row mt-4">
        <div class="col-md-4">
            <div class="card p-4 text-center">
                <c:choose>
                    <c:when test="${not empty profile.profileImage}">
                        <img src="${pageContext.request.contextPath}/resources/images/${profile.profileImage}"
                             class="profile-img mx-auto mb-3" alt="프로필 사진">
                    </c:when>
                    <c:otherwise>
                        <div class="profile-img-placeholder mx-auto mb-3">👤</div>
                    </c:otherwise>
                </c:choose>

                <c:choose>
                    <c:when test="${not empty profile}">
                        <h4 class="fw-bold"><c:out value="${not empty profile.nickname ? profile.nickname : targetUserId}"/></h4>
                        <p class="mt-2"><c:out value="${not empty profile.description ? profile.description : '소개가 없습니다.'}"/></p>
                    </c:when>
                    <c:otherwise>
                        <h4 class="fw-bold"><c:out value="${targetUserId}"/></h4>
                        <p class="text-muted">아직 프로필이 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="col-md-8">
            <h5 class="fw-bold mb-3">차량 <span class="badge bg-secondary">${cars.size()}</span></h5>
            <c:choose>
                <c:when test="${empty cars}">
                    <div class="alert alert-secondary">등록된 차량이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <div class="row g-3">
                        <c:forEach var="car" items="${cars}">
                            <div class="col-md-6">
                                <div class="card h-100">
                                    <c:choose>
                                        <c:when test="${not empty car.carImage}">
                                            <img src="${pageContext.request.contextPath}/resources/images/${car.carImage}"
                                                 class="car-img" alt="차량 사진">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="car-img-placeholder">🚗</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="card-body">
                                        <h6 class="card-title fw-bold">
                                            ${car.carBrand} ${car.carModel}
                                        </h6>
                                        <p class="card-text text-muted small">
                                            <c:if test="${car.carYear > 0}">${car.carYear}년식</c:if>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>
</div>
</body>
</html>
