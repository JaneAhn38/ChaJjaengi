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
            // 이 계정의 진짜 첫 로그인이면, 위치 공유가 이미 켜져 있는 예외적인 경우까지
            // 포함해서 무조건 위치공유 안내 팝업을 보여준다 (index.jsp에서 사용).
            session.setAttribute("forceLocationPrompt", checkAndMarkFirstLogin(user.getUserId()));

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

    /**
     * user_privacy_setting.first_login_done을 확인해서, 아직 첫 로그인 전이면
     * true를 반환하고 그 자리에서 바로 done으로 표시한다 (다음 로그인부터는 강제 안 함).
     */
    private boolean checkAndMarkFirstLogin(String userId) {
        String selectSql = "SELECT first_login_done FROM user_privacy_setting WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            boolean firstLoginDone = false;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) firstLoginDone = rs.getBoolean("first_login_done");
                }
            }
            if (firstLoginDone) return false;

            String upsertSql = "INSERT INTO user_privacy_setting (user_id, first_login_done) VALUES (?, TRUE) "
                    + "ON DUPLICATE KEY UPDATE first_login_done = TRUE";
            try (PreparedStatement ps = conn.prepareStatement(upsertSql)) {
                ps.setString(1, userId);
                ps.executeUpdate();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
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
