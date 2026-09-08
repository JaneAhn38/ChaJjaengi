package controller;

import dao.AddSpotApplicationRepository;
import dto.AddSpotApplication;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import util.FileUtil;

import java.io.IOException;

@WebServlet("/processAddSpot")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class AddSpotServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
            return;
        }

        String spotName          = request.getParameter("spotName");
        String category          = request.getParameter("category");
        String spotAddress       = request.getParameter("spot_address");
        String applicationReason = request.getParameter("application_reason");

        if (spotName == null || spotName.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/spotApplication/spotAddApplication.jsp?error=empty");
            return;
        }
        if (spotName.length() > 100) {
            response.sendRedirect(request.getContextPath() + "/spotApplication/spotAddApplication.jsp?error=toolong");
            return;
        }

        // 위도/경도는 더 이상 신청 단계에서 입력받지 않음(주소 검색으로 대체) - 승인 시 관리자가 지정
        double latitude = 0.0, longitude = 0.0;

        // 이미지 저장 (확장자 검증 + UUID 파일명)
        String savedFileName = "";
        Part filePart = request.getPart("spotImage");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadDir = getServletContext().getRealPath("/resources/images");
            try {
                savedFileName = FileUtil.saveImage(filePart, uploadDir);
            } catch (IllegalArgumentException e) {
                response.sendRedirect(request.getContextPath()
                        + "/spotApplication/spotAddApplication.jsp?error=filetype");
                return;
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        AddSpotApplication app = new AddSpotApplication();
        app.setUserId(userId);
        app.setSpotName(spotName);
        app.setSpotLatitude(latitude);
        app.setSpotLongitude(longitude);
        app.setSpotDescription(""); // 신청 단계에서는 더 이상 입력받지 않음 (DB NOT NULL 제약 때문에 빈 문자열)
        app.setSpotCategory(category != null ? category : "1");
        app.setApplicationReason(applicationReason != null ? applicationReason : "");
        app.setSpotImage(savedFileName);
        app.setSpotAddress(spotAddress != null ? spotAddress : "");

        AddSpotApplicationRepository.insert(app);

        response.sendRedirect(request.getContextPath() + "/spotApplication/applicationConfirmation.jsp");
    }
}
