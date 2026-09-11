package controller;

import dao.SpotRepository;
import dto.SpotMember;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

/**
 * "방문중인 멤버 보기" - 로그인한 유저만 조회 가능. 본인 정보 노출 범위를 최소화하기
 * 위해 목록 자체는 서버가 이미 share_profile_onOff = TRUE인 사람만 걸러서 내려준다.
 */
@WebServlet("/api/spotMembers")
public class SpotMembersApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"login_required\"}");
            return;
        }

        int spotId;
        try {
            spotId = Integer.parseInt(req.getParameter("spotId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"invalid_spotId\"}");
            return;
        }

        ArrayList<SpotMember> members = SpotRepository.getPresentSharedMembers(spotId);
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < members.size(); i++) {
            SpotMember m = members.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"userId\":\"").append(escape(m.getUserId())).append("\",")
              .append("\"nickname\":\"").append(escape(m.getNickname() != null ? m.getNickname() : m.getUserId())).append("\",")
              .append("\"profileImage\":\"").append(escape(m.getProfileImage())).append("\"")
              .append("}");
        }
        sb.append("]");

        PrintWriter out = resp.getWriter();
        out.print(sb.toString());
        out.flush();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
