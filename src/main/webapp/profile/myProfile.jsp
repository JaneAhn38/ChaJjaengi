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
    <title>AnyoneHere - 내 프로필</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <script src="../resources/js/customAlert.js"></script>
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
    ArrayList<Car> cars = CarRepository.getCarsByUserId(userId);
    request.setAttribute("profile", profile);
    request.setAttribute("cars", cars);
    request.setAttribute("userId", userId);
    String csrfToken = util.CsrfUtil.getOrCreateToken(session);
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="row mt-4">
        <!-- 프로필 카드 -->
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
                        <h4 class="fw-bold"><c:out value="${not empty profile.nickname ? profile.nickname : userId}"/></h4>
                        <p class="text-muted"><c:out value="${userId}"/></p>
                        <p class="mt-2"><c:out value="${not empty profile.description ? profile.description : '소개가 없습니다.'}"/></p>
                    </c:when>
                    <c:otherwise>
                        <h4 class="fw-bold"><c:out value="${userId}"/></h4>
                        <p class="text-muted">아직 프로필이 없습니다.</p>
                    </c:otherwise>
                </c:choose>

                <a href="${pageContext.request.contextPath}/profile/editProfile.jsp"
                   class="btn btn-outline-secondary btn-sm mt-2">프로필 수정</a>

                <!-- 위치 공유 설정 -->
                <div class="mt-3 pt-3 border-top text-start">
                    <p class="fw-bold small mb-2">위치 공유 설정</p>
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" role="switch"
                               id="locationToggle"
                               <%= Boolean.TRUE.equals(session.getAttribute("locationOn")) ? "checked" : "" %>>
                        <label class="form-check-label small" for="locationToggle" id="locationLabel">
                            <%= Boolean.TRUE.equals(session.getAttribute("locationOn")) ? "공유 중" : "공유 안 함" %>
                        </label>
                    </div>
                    <p class="text-muted" style="font-size:0.75rem;">켜면 스팟 방문자 수에 반영됩니다.<br>30분마다 계속할지 확인합니다.</p>
                </div>
            </div>
        </div>

        <!-- 차량 목록 -->
        <div class="col-md-8">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">내 차량 <span class="badge bg-secondary">${cars.size()}</span></h5>
                <button class="btn btn-primary btn-sm" data-bs-toggle="collapse"
                        data-bs-target="#addCarForm">+ 차량 추가</button>
            </div>

            <!-- 차량 추가 폼 (접기/펼치기) -->
            <div class="collapse mb-4" id="addCarForm">
                <div class="card card-body">
                    <form action="${pageContext.request.contextPath}/processAddCar"
                          method="post" enctype="multipart/form-data">
                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                        <div class="row g-2">
                            <div class="col-md-4">
                                <input type="text" name="carBrand" class="form-control"
                                       placeholder="제조사 (현대, 기아 등)" required>
                            </div>
                            <div class="col-md-4">
                                <input type="text" name="carModel" class="form-control"
                                       placeholder="모델명 (아반떼, K5 등)" required>
                            </div>
                            <div class="col-md-2">
                                <input type="number" name="carYear" class="form-control"
                                       placeholder="연식" min="1900" max="2026">
                            </div>
                            <div class="col-md-6 mt-2">
                                <label class="form-label small text-muted">차량 사진 (선택)</label>
                                <input type="file" name="carImage" class="form-control form-control-sm"
                                       accept="image/*">
                            </div>
                            <div class="col-12 mt-2">
                                <button type="submit" class="btn btn-primary btn-sm">등록</button>
                                <button type="button" class="btn btn-secondary btn-sm ms-1"
                                        data-bs-toggle="collapse" data-bs-target="#addCarForm">취소</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- 차량 카드 목록 -->
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
                                        <form action="${pageContext.request.contextPath}/processRemoveCar"
                                              method="post" class="d-inline">
                                            <input type="hidden" name="carId" value="${car.carId}">
                                            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                            <button type="submit" class="btn btn-outline-danger btn-sm"
                                                    onclick="return confirm('이 차량을 삭제하시겠습니까?')">삭제</button>
                                        </form>
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

<!-- Bootstrap JS (collapse 동작용) -->
<script>
    // 위치 공유 토글
    document.getElementById('locationToggle').addEventListener('change', function() {
        var body = new URLSearchParams();
        body.append('_csrf', '<%= csrfToken %>');
        fetch('<%= request.getContextPath() %>/toggleLocation', { method: 'POST', body: body })
            .then(r => r.json())
            .then(data => {
                document.getElementById('locationLabel').textContent =
                    data.locationOn ? '공유 중' : '공유 안 함';
            });
    });

    // Bootstrap collapse 직접 구현 (CDN 없이)
    document.querySelectorAll('[data-bs-toggle="collapse"]').forEach(btn => {
        btn.addEventListener('click', () => {
            const target = document.querySelector(btn.getAttribute('data-bs-target'));
            if (target.classList.contains('show')) {
                target.classList.remove('show');
            } else {
                target.classList.add('show');
            }
        });
    });
</script>
</body>
</html>
