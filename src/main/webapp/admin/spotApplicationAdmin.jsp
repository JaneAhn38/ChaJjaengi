<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="dto.AddSpotApplication" %>
<%@ page import="dto.RemoveSpotApplication" %>
<%@ page import="dto.PostReport" %>
<%@ page import="dao.AddSpotApplicationRepository" %>
<%@ page import="dao.RemoveSpotApplicationRepository" %>
<%@ page import="dao.PostReportRepository" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AnyoneHere - 관리자 페이지</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
</head>
<body>
<%
    // AdminFilter가 /admin/* 경로 전체를 보호하므로 여기선 역할 체크 생략
    ArrayList<AddSpotApplication> addList    = AddSpotApplicationRepository.getAllPending();
    ArrayList<RemoveSpotApplication> removeList = RemoveSpotApplicationRepository.getAllPending();
    List<PostReport> reportList              = PostReportRepository.getAllPending();
    request.setAttribute("addList",    addList);
    request.setAttribute("removeList", removeList);
    request.setAttribute("reportList", reportList);

    String csrfToken = util.CsrfUtil.getOrCreateToken(session);

    // 탭 파라미터 (신고 탭 직접 링크 지원)
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "add";
%>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="p-4 mb-4 bg-body-tertiary rounded-3">
        <h1 class="display-5 fw-bold">관리자 페이지</h1>
        <p class="fs-5">장소 신청 및 게시글 신고를 관리합니다.</p>
    </div>

    <% if ("failed".equals(request.getParameter("error"))) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- 탭 -->
    <ul class="nav nav-tabs mb-4" id="adminTab">
        <li class="nav-item">
            <a class="nav-link <%= "add".equals(activeTab) ? "active" : "" %>" data-tab="addTab" href="#">
                장소 추가 신청 <span class="badge bg-primary">${addList.size()}</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= "remove".equals(activeTab) ? "active" : "" %>" data-tab="removeTab" href="#">
                장소 삭제 신청 <span class="badge bg-danger">${removeList.size()}</span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <%= "report".equals(activeTab) ? "active" : "" %>" data-tab="reportTab" href="#">
                게시글 신고 <span class="badge bg-warning text-dark">${reportList.size()}</span>
            </a>
        </li>
    </ul>

    <div class="tab-content">

        <!-- ① 장소 추가 신청 -->
        <div class="tab-pane <%= "add".equals(activeTab) ? "show active" : "" %>" id="addTab">
            <c:choose>
                <c:when test="${empty addList}">
                    <div class="alert alert-secondary">대기 중인 장소 추가 신청이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>사진</th>
                            <th>신청자</th>
                            <th>장소명</th>
                            <th>카테고리</th>
                            <th>주소</th>
                            <th>위도/경도</th>
                            <th>신청일</th>
                            <th>처리</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="app" items="${addList}">
                            <tr>
                                <td>
                                    <c:if test="${not empty app.spotImage}">
                                        <img src="${pageContext.request.contextPath}/resources/images/${app.spotImage}"
                                             style="width:80px;height:60px;object-fit:cover;border-radius:4px;"
                                             alt="스팟 사진">
                                    </c:if>
                                    <c:if test="${empty app.spotImage}">-</c:if>
                                </td>
                                <td><c:out value="${app.userId}"/></td>
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
                                <td><c:out value="${app.spotAddress}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${app.spotLatitude == 0 && app.spotLongitude == 0}">
                                            <span class="text-danger small">변환 실패</span>
                                        </c:when>
                                        <c:otherwise>
                                            <small>${app.spotLatitude}, ${app.spotLongitude}</small>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><small>${app.createdAt}</small></td>
                                <td>
                                    <!-- 승인 -->
                                    <form action="${pageContext.request.contextPath}/admin/approveAddSpot" method="post" class="d-inline">
                                        <input type="hidden" name="applicationId" value="${app.applicationId}">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                        <button type="submit" class="btn btn-success btn-sm"
                                                onclick="return confirm('장소를 추가하시겠습니까?')">승인</button>
                                    </form>
                                    <!-- 거절 (모달) -->
                                    <button class="btn btn-danger btn-sm"
                                            onclick="openRejectModal('approveAddSpot','${app.applicationId}')">거절</button>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ② 장소 삭제 신청 -->
        <div class="tab-pane <%= "remove".equals(activeTab) ? "show active" : "" %>" id="removeTab">
            <c:choose>
                <c:when test="${empty removeList}">
                    <div class="alert alert-secondary">대기 중인 장소 삭제 신청이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>신청자</th>
                            <th>장소명</th>
                            <th>삭제 사유</th>
                            <th>신청일</th>
                            <th>처리</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="app" items="${removeList}">
                            <tr>
                                <td><c:out value="${app.userId}"/></td>
                                <td><c:out value="${app.spotName}"/> <small class="text-muted">(ID: <c:out value="${app.spotId}"/>)</small></td>
                                <td><c:out value="${app.removeReason}"/></td>
                                <td><small>${app.createdAt}</small></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin/approveRemoveSpot" method="post" class="d-inline">
                                        <input type="hidden" name="applicationId" value="${app.applicationId}">
                                        <input type="hidden" name="spotId" value="${app.spotId}">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                        <button type="submit" class="btn btn-success btn-sm"
                                                onclick="return confirm('장소를 삭제하시겠습니까? 되돌릴 수 없습니다.')">승인</button>
                                    </form>
                                    <button class="btn btn-danger btn-sm"
                                            onclick="openRejectModal('approveRemoveSpot','${app.applicationId}','${app.spotId}')">거절</button>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ③ 게시글 신고 -->
        <div class="tab-pane <%= "report".equals(activeTab) ? "show active" : "" %>" id="reportTab">
            <c:choose>
                <c:when test="${empty reportList}">
                    <div class="alert alert-secondary">대기 중인 신고가 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>신고 ID</th>
                            <th>게시글</th>
                            <th>신고자</th>
                            <th>신고 사유</th>
                            <th>신고일</th>
                            <th>처리</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="rpt" items="${reportList}">
                            <tr>
                                <td>${rpt.reportId}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/community/post.jsp?postId=<c:out value="${rpt.postId}"/>"
                                       target="_blank"><c:out value="${rpt.postTitle}"/></a>
                                </td>
                                <td><c:out value="${rpt.reporterName}"/></td>
                                <td><c:out value="${rpt.reason}"/></td>
                                <td><small>${rpt.createdAt}</small></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin/handlePostReport" method="post" class="d-inline">
                                        <input type="hidden" name="reportId" value="${rpt.reportId}">
                                        <input type="hidden" name="action" value="reviewed">
                                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                        <button type="submit" class="btn btn-warning btn-sm"
                                                onclick="return confirm('신고를 처리 완료 상태로 변경합니까?')">처리완료</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin/handlePostReport" method="post" class="d-inline">
                                        <input type="hidden" name="reportId" value="${rpt.reportId}">
                                        <input type="hidden" name="action" value="dismissed">
                                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                        <button type="submit" class="btn btn-secondary btn-sm"
                                                onclick="return confirm('신고를 기각하시겠습니까?')">기각</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

    </div><!-- /tab-content -->

    <%@ include file="../common/footer.jsp" %>
</div>

<!-- 거절 사유 입력 모달 -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="rejectForm" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="applicationId" id="rejectAppId">
                <input type="hidden" name="spotId" id="rejectSpotId">
                <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                <div class="modal-header">
                    <h5 class="modal-title">거절 사유 입력</h5>
                    <button type="button" class="btn-close" onclick="closeModal()"></button>
                </div>
                <div class="modal-body">
                    <label class="form-label">거절 사유 <small class="text-muted">(신청자에게 표시됩니다)</small></label>
                    <textarea name="rejectReason" class="form-control" rows="3"
                              placeholder="거절 사유를 입력하세요 (선택)" maxlength="300"></textarea>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeModal()">취소</button>
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('신청을 거절하시겠습니까?')">거절</button>
                </div>
            </form>
        </div>
    </div>
</div>
<div class="modal-backdrop fade" id="modalBackdrop" style="display:none;"></div>

<script>
    const ctxPath = '<%= request.getContextPath() %>';

    // 탭 전환
    const tabLinks = document.querySelectorAll('[data-tab]');
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            tabLinks.forEach(l => l.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('show', 'active'));
            this.classList.add('active');
            document.getElementById(this.dataset.tab).classList.add('show', 'active');
        });
    });

    // 거절 모달
    function openRejectModal(action, appId, spotId) {
        document.getElementById('rejectForm').action = ctxPath + '/admin/' + action;
        document.getElementById('rejectAppId').value = appId;
        document.getElementById('rejectSpotId').value = spotId || '';
        document.getElementById('rejectModal').style.display = 'block';
        document.getElementById('rejectModal').classList.add('show');
        document.getElementById('modalBackdrop').style.display = 'block';
        document.getElementById('modalBackdrop').classList.add('show');
    }

    function closeModal() {
        document.getElementById('rejectModal').style.display = 'none';
        document.getElementById('rejectModal').classList.remove('show');
        document.getElementById('modalBackdrop').style.display = 'none';
        document.getElementById('modalBackdrop').classList.remove('show');
    }
</script>
</body>
</html>
