package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import dao.UserRepository;
import dto.User;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/processLoginMember")
public class LoginMemberServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String id       = request.getParameter("id");
        String password = request.getParameter("password");

        if (id == null || id.isBlank() || password == null || password.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp?error=true");
            return;
        }

        // validateUser가 User 객체를 반환 — DB 조회 1회로 해결
        User user = UserRepository.validateUser(id, password);

        if (user != null) {
            // 세션 고정 공격 방지: 기존 세션 무효화 후 새 세션 발급
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userRole",
                    user.getUserRole() != null ? user.getUserRole() : "USER");
            session.setAttribute("locationOn", loadLocationSetting(user.getUserId()));
            session.setAttribute("profileShareOn", loadProfileShareSetting(user.getUserId()));
            session.setAttribute("userAddress", user.getUserAddress());

            response.sendRedirect(request.getContextPath() + "/index.jsp?justLoggedIn=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp?error=true");
        }
    }

    private boolean loadLocationSetting(String userId) {
        String sql = "SELECT show_location_onOff FROM user_privacy_setting WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBoolean("show_location_onOff");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean loadProfileShareSetting(String userId) {
        String sql = "SELECT share_profile_onOff FROM user_privacy_setting WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBoolean("share_profile_onOff");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
