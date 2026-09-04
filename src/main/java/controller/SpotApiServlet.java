package controller;

import dao.SpotRepository;
import dto.Spot;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

@WebServlet("/api/spots")
public class SpotApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        ArrayList<Spot> spots = SpotRepository.getAllSpots();
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < spots.size(); i++) {
            Spot s = spots.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"spotId\":").append(s.getSpotId()).append(",")
              .append("\"name\":\"").append(escape(s.getSpotName())).append("\",")
              .append("\"latitude\":").append(s.getSpotLatitude()).append(",")
              .append("\"longitude\":").append(s.getSpotLongitude()).append(",")
              .append("\"activeUserCount\":").append(s.getActiveUserCount())
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
