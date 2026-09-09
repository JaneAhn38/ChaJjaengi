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

@WebServlet("/updateLocation")
public class UpdateLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"로그인 필요\"}");
            return;
        }

        if (!isLocationAllowed(userId)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"위치 공개 비동의\"}");
            return;
        }

        double latitude, longitude;
        try {
            latitude  = Double.parseDouble(request.getParameter("latitude"));
            longitude = Double.parseDouble(request.getParameter("longitude"));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"status\":\"error\",\"message\":\"잘못된 좌표\"}");
            return;
        }

        insertLocationLog(userId, latitude, longitude);
        upsertCurrentLocation(userId, latitude, longitude);
        response.getWriter().write("{\"status\":\"ok\"}");
    }

    private boolean isLocationAllowed(String userId) {
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

    private void insertLocationLog(String userId, double latitude, double longitude) {
        String sql = "INSERT INTO location_logs (user_id, latitude, longitude) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 스팟 반경 계산은 이 "현재 위치" 테이블을 기준으로 하므로, 이력 저장과 별개로 항상 갱신해야 함. */
    private void upsertCurrentLocation(String userId, double latitude, double longitude) {
        String sql = """
            INSERT INTO user_current_location (user_id, current_latitude, current_longitude, updated_at)
            VALUES (?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE
                current_latitude  = VALUES(current_latitude),
                current_longitude = VALUES(current_longitude),
                updated_at        = NOW()
            """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
