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

@WebServlet("/processUpdatePost")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class UpdatePostServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginMember.jsp");
            return;
        }

        String postIdStr = request.getParameter("postId");
        int postId;
        try {
            postId = Integer.parseInt(postIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/community/board.jsp");
            return;
        }

        String category = request.getParameter("category");
        String title    = request.getParameter("title");
        String content  = request.getParameter("content");

        if (title == null || title.isBlank() || content == null || content.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/community/editPost.jsp?postId=" + postId + "&error=empty");
            return;
        }
        if (title.length() > 100) {
            response.sendRedirect(request.getContextPath() + "/community/editPost.jsp?postId=" + postId + "&error=toolong");
            return;
        }
        if (content.length() > 5000) {
            response.sendRedirect(request.getContextPath() + "/community/editPost.jsp?postId=" + postId + "&error=toolong");
            return;
        }

        Post post = new Post();
        post.setPostId(postId);
        post.setUserId(userId);  // Repository에서 userId로 본인 글 검증
        post.setCategory(category != null ? category : "FREE");
        post.setTitle(title.trim());
        post.setContent(content.trim());
        PostRepository.update(post);

        // 선택된 이미지 삭제 (Cloudinary 쪽 파일은 그대로 두고 DB 연결만 삭제 - 무료
        // 플랜 용량 안에서는 굳이 정리 API까지 호출할 필요 없음)
        String[] deleteIds = request.getParameterValues("deleteImageIds");
        if (deleteIds != null) {
            for (String idStr : deleteIds) {
                try {
                    int imageId = Integer.parseInt(idStr);
                    PostImageRepository.deleteImage(imageId, postId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        // 새 이미지 추가 (Cloudinary)
        List<String> newImages = new ArrayList<>();
        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if ("postImages".equals(part.getName()) && part.getSize() > 0) {
                try {
                    newImages.add(CloudinaryUtil.uploadImage(part));
                } catch (IllegalArgumentException e) {
                    // 허용되지 않는 확장자는 건너뜀
                } catch (Exception e) {
                    // 업로드 실패 시 해당 이미지만 건너뜀 (게시글 수정 자체는 유지)
                    e.printStackTrace();
                }
            }
        }
        if (!newImages.isEmpty()) {
            PostImageRepository.insertImages(postId, newImages);
        }

        response.sendRedirect(request.getContextPath() + "/community/post.jsp?postId=" + postId);
    }
}
