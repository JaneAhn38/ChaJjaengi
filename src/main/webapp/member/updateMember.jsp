<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserRepository" %>
<%@ page import="dto.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <title>개인정보 수정</title>
</head>
<body>
<%
    String sessionId = (String) session.getAttribute("userId");
    if (sessionId == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
        return;
    }

    User user = UserRepository.getUserById(sessionId);
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String csrfToken = util.CsrfUtil.getOrCreateToken(session);

    // 이메일 분리
    String email = user.getUserEmail() != null ? user.getUserEmail() : "";
    String[] emailParts = email.contains("@") ? email.split("@") : new String[]{email, ""};
    String mail1 = emailParts[0];
    String mail2 = emailParts.length > 1 ? emailParts[1] : "";

    // 생년월일 분리
    String birthStr = user.getUserBirth() != null ? user.getUserBirth().toString() : "--";
    String[] birthParts = birthStr.split("-");
    String birthYY = birthParts.length > 0 ? birthParts[0] : "";
    String birthMM = birthParts.length > 1 ? birthParts[1] : "";
    String birthDD = birthParts.length > 2 ? birthParts[2] : "";

    // 전화번호 분리
    String phone = user.getUserPhone() != null ? user.getUserPhone() : "--";
    String[] phoneParts = phone.split("-");
    String phone1 = phoneParts.length > 0 ? phoneParts[0] : "010";
    String phone2 = phoneParts.length > 1 ? phoneParts[1] : "";
    String phone3 = phoneParts.length > 2 ? phoneParts[2] : "";
%>

<div class="container py-4">
    <jsp:include page="../common/menu.jsp"/>

    <div class="py-4">
        <h1 class="fw-bold" style="color:#1C1C1E;">개인정보 수정</h1>
        <p class="fs-5" style="color:var(--figma-text-gray);">Membership Updating</p>
    </div>

    <% if ("delete".equals(request.getParameter("error"))) { %>
    <div class="alert alert-danger">탈퇴 처리 중 오류가 발생했습니다. 다시 시도해주세요.</div>
    <% } %>

    <form name="newMember" action="<%= request.getContextPath() %>/processUpdateMember"
          method="post" onsubmit="return checkForm()">
        <input type="hidden" name="_csrf" value="<%= csrfToken %>">

        <div class="mb-3 row">
            <label class="col-sm-2">아이디</label>
            <div class="col-sm-3">
                <input name="id" type="text" class="form-control" value="<%= user.getUserId() %>" readonly>
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">새 비밀번호</label>
            <div class="col-sm-3">
                <input name="password" type="password" class="form-control"
                       placeholder="변경할 경우에만 입력 (미입력 시 유지)">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">비밀번호 확인</label>
            <div class="col-sm-3">
                <input name="password_confirm" type="password" class="form-control">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">성명</label>
            <div class="col-sm-3">
                <input name="name" type="text" class="form-control" value="<%= util.HtmlUtil.escape(user.getUserName() != null ? user.getUserName() : "") %>">
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">성별</label>
            <div class="col-sm-3">
                <input name="gender" type="radio" value="남" <%= "남".equals(user.getUserGender()) || (user.getUserGender() != null && user.getUserGender().startsWith("남")) ? "checked" : "" %>> 남
                <input name="gender" type="radio" value="여" <%= "여".equals(user.getUserGender()) || (user.getUserGender() != null && user.getUserGender().startsWith("여")) ? "checked" : "" %>> 여
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">생일</label>
            <div class="col-sm-10">
                <div class="row">
                    <div class="col-sm-2">
                        <input type="text" name="birthyy" maxlength="4" class="form-control" value="<%= birthYY %>">
                    </div>
                    <div class="col-sm-2">
                        <select name="birthmm" id="birthmm" class="form-select">
                            <option value="">월</option>
                            <% for (int i = 1; i <= 12; i++) {
                                String val = String.format("%02d", i);
                                boolean selected = val.equals(birthMM);
                            %>
                            <option value="<%= val %>" <%= selected ? "selected" : "" %>><%= i %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-sm-2">
                        <input type="text" name="birthdd" maxlength="2" class="form-control" value="<%= birthDD %>">
                    </div>
                </div>
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">이메일</label>
            <div class="col-sm-10">
                <div class="row align-items-center">
                    <div class="col-sm-4">
                        <input type="text" name="mail1" value="<%= mail1 %>" class="form-control">
                    </div>
                    <div class="col-auto">@</div>
                    <div class="col-sm-3">
                        <select name="mail2" id="mail2" class="form-select">
                            <% String[] domains = {"naver.com","daum.net","gmail.com","nate.com"};
                               for (String d : domains) { %>
                            <option value="<%= d %>" <%= d.equals(mail2) ? "selected" : "" %>><%= d %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">전화번호</label>
            <div class="col-sm-10">
                <div class="row align-items-center">
                    <div class="col-sm-2">
                        <select name="phone1" class="form-select">
                            <% String[] phonePrefixes = {"010","011","012","013","014","015","016","017","018","019"};
                               for (String p : phonePrefixes) { %>
                            <option value="<%= p %>" <%= p.equals(phone1) ? "selected" : "" %>><%= p %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-auto">-</div>
                    <div class="col-sm-2">
                        <input type="text" name="phone2" maxlength="4" class="form-control" value="<%= phone2 %>">
                    </div>
                    <div class="col-auto">-</div>
                    <div class="col-sm-2">
                        <input type="text" name="phone3" maxlength="4" class="form-control" value="<%= phone3 %>">
                    </div>
                </div>
            </div>
        </div>
        <div class="mb-3 row">
            <label class="col-sm-2">주소</label>
            <div class="col-sm-5">
                <input name="address" type="text" class="form-control" value="<%= util.HtmlUtil.escape(user.getUserAddress() != null ? user.getUserAddress() : "") %>">
            </div>
        </div>
        <div class="mb-3 row">
            <div class="col-sm-offset-2 col-sm-10">
                <input type="submit" class="btn btn-primary" value="회원수정">
            </div>
        </div>
    </form>

    <!-- 회원탈퇴: POST form -->
    <hr class="my-4">
    <form action="<%= request.getContextPath() %>/processDeleteMember" method="post"
          onsubmit="return confirm('정말로 탈퇴하시겠습니까? 모든 데이터가 삭제되며 되돌릴 수 없습니다.')">
        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
        <button type="submit" class="btn btn-outline-danger">회원 탈퇴</button>
    </form>

    <jsp:include page="../common/footer.jsp"/>
</div>

<script>
function checkForm() {
    const form = document.newMember;
    if (!form.password.value && !form.password_confirm.value) return true; // 비밀번호 미변경
    if (form.password.value !== form.password_confirm.value) {
        showAlert("비밀번호를 동일하게 입력하세요.");
        return false;
    }
    return true;
}
</script>
</body>
</html>
