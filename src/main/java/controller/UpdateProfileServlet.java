package controller;

import dao.ProfileRepository;
import dto.Profile;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import util.CloudinaryUtil;

import java.io.IOException;

@WebServlet("/processUpdateProfile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
            return;
        }

        String nickname    = request.getParameter("nickname");
        String description = request.getParameter("description");
        if (nickname    == null) nickname    = "";
        if (description == null) description = "";

        if (nickname.length() > 10) {
            response.sendRedirect(request.getContextPath() + "/profile/editProfile.jsp?error=toolong");
            return;
        }
        if (description.length() > 500) {
            response.sendRedirect(request.getContextPath() + "/profile/editProfile.jsp?error=toolong");
            return;
        }

        // 기존 프로필 이미지 유지 or 새 이미지 저장
        Profile existing = ProfileRepository.getProfileByUserId(userId);
        String profileImage = (existing != null && existing.getProfileImage() != null)
                ? existing.getProfileImage() : "";

        Part filePart = request.getPart("profileImage");
        if (filePart != null && filePart.getSize() > 0) {
            try {
                profileImage = CloudinaryUtil.uploadImage(filePart);
            } catch (IllegalArgumentException e) {
                response.sendRedirect(request.getContextPath()
                        + "/profile/editProfile.jsp?error=filetype");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath()
                        + "/profile/editProfile.jsp?error=upload");
                return;
            }
        }

        Profile profile = new Profile();
        profile.setUserId(userId);
        profile.setNickname(nickname);
        profile.setDescription(description);
        profile.setProfileImage(profileImage);

        ProfileRepository.upsertProfile(profile);

        response.sendRedirect(request.getContextPath() + "/profile/myProfile.jsp");
    }
}
