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

@WebServlet("/processLogoutMember")
public class LogoutMemberServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            String userId = (String) session.getAttribute("userId");
            // 로그아웃하면 스팟 인원 집계에서도 즉시 빠지도록 현재 위치 기록을 지움
            // (안 지우면 user_current_location이 그대로 남아 최대 10분간 계속 집계됨)
            if (userId != null) clearCurrentLocation(userId);
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
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
