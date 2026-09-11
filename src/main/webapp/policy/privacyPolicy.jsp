<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>개인정보처리방침 | 차쟁이</title>
    <link rel="stylesheet" href="../resources/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../resources/css/theme.css"/>
    <style>
        .policy-body h2 { font-size: 1.15rem; font-weight: 800; margin-top: 2rem; margin-bottom: 0.6rem; }
        .policy-body h3 { font-size: 1rem; font-weight: 700; margin-top: 1.2rem; margin-bottom: 0.4rem; }
        .policy-body p, .policy-body li { color: #3a3a3c; line-height: 1.7; }
        .policy-body table { width: 100%; margin: 0.8rem 0; }
        .policy-body table th, .policy-body table td { border: 1px solid #e5e5ea; padding: 8px 12px; font-size: 0.9rem; }
        .policy-body table th { background: #f7f7fa; }
    </style>
</head>
<body>
<div class="container py-4">
    <%@ include file="../common/menu.jsp" %>

    <div class="py-4">
        <h1 class="fw-bold" style="color:#1C1C1E;">개인정보처리방침</h1>
        <p class="text-muted">시행일자: 2026년 9월 11일</p>
    </div>

    <div class="policy-body" style="max-width: 860px;">
        <p>
            차쟁이(AnyoneHere, 이하 "서비스")는 이용자의 개인정보를 중요하게 생각하며,
            「개인정보 보호법」 등 관련 법령을 준수합니다. 이 방침은 서비스가 어떤 개인정보를
            수집·이용·보관·파기하는지 안내합니다.
        </p>

        <h2>1. 수집하는 개인정보 항목</h2>
        <h3>가) 회원가입 시 (필수)</h3>
        <p>아이디, 비밀번호(암호화 저장), 이름, 성별, 생년월일, 이메일, 전화번호, 주소</p>
        <h3>나) 서비스 이용 과정에서 선택적으로 수집</h3>
        <ul>
            <li>프로필: 닉네임, 자기소개, 프로필 사진</li>
            <li>차량 정보: 제조사, 모델명, 연식, 차량 사진 (등록 시)</li>
            <li>실시간 위치정보: "위치 공유"를 켠 경우에만 수집 (스팟 방문자 수 집계 목적)</li>
            <li>커뮤니티 이용 기록: 작성한 게시글·댓글·리뷰·좋아요·신고 내역</li>
            <li>장소 등록/삭제 신청 시 입력한 주소 및 신청 사유</li>
        </ul>
        <h3>다) 자동으로 생성·수집되는 정보</h3>
        <p>서비스 이용 기록, 접속 세션(쿠키)</p>

        <h2>2. 개인정보 수집·이용 목적</h2>
        <ul>
            <li>회원 식별, 로그인 인증, 부정 이용 방지</li>
            <li>드라이브 스팟의 실시간 방문 인원 집계 및 제공 (위치정보 활용)</li>
            <li>같은 스팟 방문자 간 프로필 공개 (본인이 "정보 공유"에 동의한 경우에 한함)</li>
            <li>커뮤니티 게시판, 리뷰, 찜하기 등 부가 서비스 제공</li>
            <li>장소 등록/삭제 신청 접수 및 처리</li>
            <li>문의 응대 및 서비스 개선</li>
        </ul>

        <h2>3. 보유 및 이용 기간</h2>
        <p>
            회원 탈퇴 시 지체 없이 파기합니다. 다만 관계 법령에 따라 보존할 의무가 있는 경우
            해당 기간 동안 별도 보관 후 파기합니다.
        </p>

        <h2>4. 개인정보의 제3자 제공 및 처리위탁</h2>
        <p>서비스는 이용자의 동의 없이 개인정보를 외부에 제공하지 않습니다. 다만 서비스 운영을 위해
            아래와 같은 외부 사업자의 서버(해외 소재 포함)를 이용하며, 이 과정에서 관련 정보가
            국외에 저장·처리될 수 있습니다.</p>
        <table>
            <tr><th>수탁업체</th><th>위탁 업무</th></tr>
            <tr><td>Render</td><td>애플리케이션 서버 호스팅</td></tr>
            <tr><td>Aiven</td><td>데이터베이스 호스팅</td></tr>
            <tr><td>Cloudinary</td><td>업로드 이미지(프로필/차량/스팟/게시글) 저장</td></tr>
            <tr><td>카카오(Kakao)</td><td>주소 검색 및 좌표 변환(지오코딩) API</td></tr>
        </table>

        <h2>5. 이용자의 권리와 행사 방법</h2>
        <ul>
            <li>이용자는 언제든지 마이페이지에서 본인의 개인정보(이름/연락처/주소 등)를 조회·수정할 수 있습니다.</li>
            <li>위치 공유 및 프로필 공개 설정은 마이페이지에서 언제든지 켜고 끌 수 있습니다.</li>
            <li>회원 탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.</li>
        </ul>

        <h2>6. 개인정보의 파기</h2>
        <p>파기 사유가 발생한 개인정보는 지체 없이 파기하며, 전자적 파일은 복구 불가능한 방법으로 삭제합니다.</p>

        <h2>7. 개인정보 보호책임자</h2>
        <p>서비스 운영자: 차쟁이 운영팀<br>
            이메일: (문의용 이메일 주소를 입력해주세요)</p>

        <h2>8. 고지의 의무</h2>
        <p>이 방침의 내용은 서비스 개선, 법령 변경 등에 따라 수정될 수 있으며, 변경 시 이 페이지를 통해
            공지합니다.</p>
    </div>

    <%@ include file="../common/footer.jsp" %>
</div>
</body>
</html>
