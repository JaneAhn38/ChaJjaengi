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

@WebServlet("/toggleLocation")
public class ToggleLocationServlet extends HttpServlet {

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

        // state 파라미터가 있으면 그 값으로 설정, 없으면 현재 값 반전
        String stateParam = request.getParameter("state");
        boolean newState;
        if ("on".equals(stateParam)) {
            newState = setState(userId, true);
        } else if ("off".equals(stateParam)) {
            newState = setState(userId, false);
        } else {
            newState = toggleCurrent(userId);
        }
        session.setAttribute("locationOn", newState);
        response.getWriter().write("{\"status\":\"ok\",\"locationOn\":" + newState + "}");
    }

    /** 현재 값 읽어서 반전 후 저장 */
    private boolean toggleCurrent(String userId) {
        boolean current = false;
        boolean exists  = false;

        String selectSql = "SELECT show_location_onOff FROM user_privacy_setting WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists  = true;
                    current = rs.getBoolean("show_location_onOff");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return setState(userId, !current, exists);
    }

    /** 지정한 값으로 설정 */
    private boolean setState(String userId, boolean value) {
        return setState(userId, value, null);
    }

    private boolean setState(String userId, boolean value, Boolean exists) {
        if (exists == null) {
            // exists 여부 확인
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
                ? "UPDATE user_privacy_setting SET show_location_onOff = ? WHERE user_id = ?"
                : "INSERT INTO user_privacy_setting (user_id, show_location_onOff) VALUES (?, ?)";

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

        // 꺼졌으면 남아있는 현재 위치 기록도 바로 지워서, 유예 시간(10분) 없이
        // 즉시 스팟 인원 집계에서 빠지도록 함
        if (!value) clearCurrentLocation(userId);

        return value;
    }

    private void clearCurrentLocation(String userId) {
        String sql = "DELETE FROM user_current_location WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
