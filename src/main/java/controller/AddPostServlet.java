package controller;

import dao.PostImageRepository;
import dao.PostRepository;
import dto.Post;
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
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@WebServlet("/processAddPost")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class AddPostServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
            return;
        }

        String category = request.getParameter("category");
        String title    = request.getParameter("title");
        String content  = request.getParameter("content");

        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/community/addPost.jsp?error=empty");
            return;
        }
        if (title.length() > 100) {
            response.sendRedirect(request.getContextPath() + "/community/addPost.jsp?error=toolong");
            return;
        }
        if (content.length() > 5000) {
            response.sendRedirect(request.getContextPath() + "/community/addPost.jsp?error=toolong");
            return;
        }

        Post post = new Post();
        post.setUserId(userId);
        post.setCategory(category != null ? category : "FREE");
        post.setTitle(title.trim());
        post.setContent(content.trim());

        int postId = PostRepository.insert(post);
        if (postId == -1) {
            response.sendRedirect(request.getContextPath() + "/community/addPost.jsp?error=fail");
            return;
        }

        // 이미지 업로드 (Cloudinary)
        List<String> savedImages = new ArrayList<>();
        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if ("postImages".equals(part.getName()) && part.getSize() > 0) {
                try {
                    savedImages.add(CloudinaryUtil.uploadImage(part));
                } catch (IllegalArgumentException e) {
                    // 허용되지 않는 확장자는 건너뜀
                } catch (Exception e) {
                    // 업로드 실패 시 해당 이미지만 건너뜀 (게시글 자체는 유지)
                    e.printStackTrace();
                }
            }
        }
        if (!savedImages.isEmpty()) {
            PostImageRepository.insertImages(postId, savedImages);
        }

        response.sendRedirect(request.getContextPath() + "/community/post.jsp?postId=" + postId);
    }
}
