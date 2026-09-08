package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import dao.ProfileRepository;
import dao.UserRepository;
import dto.Profile;
import dto.User;
import util.DBUtil;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/processAddMember")
public class AddMemberServlet extends HttpServlet {

    private void initPrivacySetting(String userId) {
        String sql = "INSERT IGNORE INTO user_privacy_setting (user_id, show_location_onOff) VALUES (?, FALSE)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");
        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("password_confirm");

        if (id == null || id.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=id");
            return;
        }
        if (password == null || password.length() < 8) {
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=password");
            return;
        }
        if (!password.equals(passwordConfirm)) {
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=passwordMismatch");
            return;
        }
        String name = request.getParameter("name");
        String gender = request.getParameter("gender");

        String year  = request.getParameter("birthyy");
        String month = request.getParameter("birthmm");
        String day   = request.getParameter("birthdd");

        String birth;
        try {
            birth = String.format("%s-%02d-%02d", year,
                    Integer.parseInt(month), Integer.parseInt(day));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=birth");
            return;
        }

        String mail1      = request.getParameter("mail1");
        String mail2Custom = request.getParameter("mail2");
        String mail2Select = request.getParameter("mail2_select");
        String mail2 = (mail2Custom != null && !mail2Custom.isEmpty()) ? mail2Custom : mail2Select;

        if (mail1 == null || mail1.isBlank() || mail2 == null || mail2.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=email");
            return;
        }
        String email = mail1.trim() + "@" + mail2.trim();

        String p1 = request.getParameter("phone1");
        String p2 = request.getParameter("phone2");
        String p3 = request.getParameter("phone3");
        String phone = (p1 != null ? p1 : "") + "-"
                     + (p2 != null ? p2 : "") + "-"
                     + (p3 != null ? p3 : "");
        String address = request.getParameter("address");

        User user = new User();
        user.setUserId(id);
        user.setUserPassword(PasswordUtil.hash(password));  // 해싱 후 저장
        user.setUserName(name);
        user.setUserGender(gender);
        user.setUserEmail(email);
        user.setUserPhone(phone);
        user.setUserAddress(address);
        user.setUserBirth(java.time.LocalDate.parse(birth));
        user.setCreatedAt(java.time.LocalDate.now());

        boolean success = UserRepository.addUser(user);

        if (!success) {
            // 아이디 또는 이메일 중복
            response.sendRedirect(request.getContextPath() + "/member/addMember.jsp?error=dup");
            return;
        }

        // 회원가입 성공 시 빈 profile row 자동 생성
        Profile profile = new Profile();
        profile.setUserId(id);
        ProfileRepository.upsertProfile(profile);

        // 위치 공유 설정 기본값 생성 (기본: 비공개)
        initPrivacySetting(id);

        response.sendRedirect(request.getContextPath() + "/member/resultMember.jsp?msg=1");
    }
}
