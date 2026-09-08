<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%><html>
<head>
    <title>exceptionInternalError</title>
</head>
<body>
<div class="container py-4">
    <%@ include file="../common/menu.jsp"%>
    <div class="p-5 mb-4 bg-body-tertiary rounded-3">
        <div class="container-fluid py-5">
            <h1 class="alert alert-danger">잠시 후 다시 시도해주세요.</h1>
        </div>
    </div>
    <div class="row align-items-md-stretch">
        <div class="col-md-12">
            <div class="h-100 p-5">
                <p>
                        <%=request.getRequestURL()%>?<%=request.getQueryString()%>
                <p>
                    <a href="../index.jsp" class="btn btn-secondary"> 홈으로 돌아가기
                        &raquo;</a>
            </div>
        </div>
    </div>
    <%@ include file="../common/footer.jsp"%>
</div>
</body>
</html>
