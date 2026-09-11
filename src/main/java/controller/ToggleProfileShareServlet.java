package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * "같은 스팟에 있는 다른 방문자에게 내 프로필(닉네임/소개/차량)을 공개할지" 설정.
 * ToggleLocationServlet과 같은 구조 (state on/off/토글, user_privacy_setting에 upsert).
 */
@WebServlet("/toggleProfileShare")
public class ToggleProfileShareServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\":\"error\"}");
            return;
        }

        String stateParam = request.getParameter("state");
        boolean newState;
        if ("on".equals(stateParam)) {
            newState = setState(userId, true);
        } else if ("off".equals(stateParam)) {
            newState = setState(userId, false);
        } else {
            newState = toggleCurrent(userId);
        }
        session.setAttribute("profileShareOn", newState);
        response.getWriter().write("{\"status\":\"ok\",\"profileShareOn\":" + newState + "}");
    }

    private boolean toggleCurrent(String userId) {
        boolean current = false;
        boolean exists  = false;

        String selectSql = "SELECT share_profile_onOff FROM user_privacy_setting WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists  = true;
                    current = rs.getBoolean("share_profile_onOff");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return setState(userId, !current, exists);
    }

    private boolean setState(String userId, boolean value) {
        return setState(userId, value, null);
    }

    private boolean setState(String userId, boolean value, Boolean exists) {
        if (exists == null) {
            String checkSql = "SELECT 1 FROM user_privacy_setting WHERE user_id = ?";
            exists = false;
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) exists = true;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        String upsertSql = exists
                ? "UPDATE user_privacy_setting SET share_profile_onOff = ? WHERE user_id = ?"
                : "INSERT INTO user_privacy_setting (user_id, share_profile_onOff) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(upsertSql)) {
            if (exists) {
                ps.setBoolean(1, value);
                ps.setString(2, userId);
            } else {
                ps.setString(1, userId);
                ps.setBoolean(2, value);
            }
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return value;
    }
}
