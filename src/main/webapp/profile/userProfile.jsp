<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dto.Profile" %>
<%@ page import="dto.Car" %>
<%@ page import="dao.ProfileRepository" %>
<%@ page import="dao.CarRepository" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 프로필</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
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
    String targetUserId = request.getParameter("userId");
    if (targetUserId == null || targetUserId.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    Profile profile = ProfileRepository.getProfileByUserId(targetUserId);
    ArrayList<Car> cars = CarRepository.getCarsByUserId(targetUserId);
    request.setAttribute("profile", profile);
    request.setAttribute("cars", cars);
    request.setAttribute("targetUserId", targetUserId);

    String loginUserId = (String) session.getAttribute("userId");
    boolean isMyProfile = targetUserId.equals(loginUserId);
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="row mt-4">
        <!-- 프로필 카드 -->
        <div class="col-md-4">
            <div class="card p-4 text-center">
                <c:choose>
                    <c:when test="${not empty profile.profileImage}">
                        <img src="${profile.profileImage}"
                             class="profile-img mx-auto mb-3" alt="프로필 사진">
                    </c:when>
                    <c:otherwise>
                        <div class="profile-img-placeholder mx-auto mb-3">👤</div>
                    </c:otherwise>
                </c:choose>

                <c:choose>
                    <c:when test="${not empty profile}">
                        <h4 class="fw-bold"><c:out value="${not empty profile.nickname ? profile.nickname : targetUserId}"/></h4>
                        <p class="text-muted"><c:out value="${targetUserId}"/></p>
                        <p class="mt-2"><c:out value="${not empty profile.description ? profile.description : '소개가 없습니다.'}"/></p>
                    </c:when>
                    <c:otherwise>
                        <h4 class="fw-bold"><c:out value="${targetUserId}"/></h4>
                        <p class="text-muted">아직 프로필이 없습니다.</p>
                    </c:otherwise>
                </c:choose>

                <% if (isMyProfile) { %>
                <a href="${pageContext.request.contextPath}/profile/editProfile.jsp"
                   class="btn btn-outline-secondary btn-sm mt-2">프로필 수정</a>
                <% } %>
            </div>
        </div>

        <!-- 차량 목록 -->
        <div class="col-md-8">
            <h5 class="fw-bold mb-3">보유 차량 <span class="badge bg-secondary">${cars.size()}</span></h5>

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
                                            <img src="${car.carImage}"
                                                 class="car-img" alt="차량 사진">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="car-img-placeholder">🚗</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="card-body">
                                        <h6 class="card-title fw-bold">${car.carBrand} ${car.carModel}</h6>
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
