package dao;

import dto.User;
import util.DBUtil;
import util.PasswordUtil;

import java.sql.*;

public class UserRepository {

    public static User getUserById(String id) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getString("user_id"));
                    user.setUserPassword(rs.getString("user_password"));
                    user.setUserName(rs.getString("user_name"));
                    user.setUserEmail(rs.getString("user_email"));
                    user.setUserPhone(rs.getString("user_phone"));
                    user.setUserAddress(rs.getString("user_address"));
                    user.setUserGender(rs.getString("user_gender"));
                    Date userBirth = rs.getDate("user_birth");
                    if (userBirth != null) user.setUserBirth(userBirth.toLocalDate());
                    Date joinDate = rs.getDate("created_at");
                    if (joinDate != null) user.setCreatedAt(joinDate.toLocalDate());
                    user.setUserRole(rs.getString("user_role"));
                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 로그인 검증. 성공 시 User 객체 반환, 실패 시 null 반환.
     */
    public static User validateUser(String id, String password) {
        if (id == null || password == null) return null;
        User user = getUserById(id);
        if (user == null) return null;
        try {
            return PasswordUtil.verify(password, user.getUserPassword()) ? user : null;
        } catch (Exception e) {
            // 저장된 해시 형식이 깨졌거나(과거 마이그레이션 이전 데이터 등) 암호화
            // 알고리즘 관련 문제가 생겨도 500 에러로 죽지 않고 로그인 실패로 처리
            e.printStackTrace();
            return null;
        }
    }

    public static void updateUser(User user) {
        String sql = "UPDATE users SET "
                + "user_password=?, user_name=?, user_email=?, user_phone=?, "
                + "user_address=?, user_gender=?, user_birth=? "
                + "WHERE user_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUserPassword());
            ps.setString(2, user.getUserName());
            ps.setString(3, user.getUserEmail());
            ps.setString(4, user.getUserPhone());
            ps.setString(5, user.getUserAddress());
            ps.setString(6, user.getUserGender());
            if (user.getUserBirth() != null) {
                ps.setDate(7, Date.valueOf(user.getUserBirth()));
            } else {
                ps.setNull(7, Types.DATE);
            }
            ps.setString(8, user.getUserId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 해당 유저가 "같은 스팟 방문자에게 프로필 공개"에 동의했는지. URL 직접 접근으로
     *  동의 안 한 사람 프로필을 열람하는 걸 막기 위한 서버 사이드 체크용. */
    public static boolean isProfileShared(String userId) {
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

    /** 회원 탈퇴 */
    public static boolean deleteUser(String userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 회원가입. 성공 시 true, 아이디/이메일 중복 등 실패 시 false 반환.
     * 비밀번호는 호출 전에 PasswordUtil.hash()로 해시해야 함.
     */
    public static boolean addUser(User user) {
        String sql = "INSERT INTO users "
                + "(user_id, user_password, user_name, user_email, "
                + "user_phone, user_address, user_gender, user_birth, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUserId());
            ps.setString(2, user.getUserPassword());
            ps.setString(3, user.getUserName());
            ps.setString(4, user.getUserEmail());
            ps.setString(5, user.getUserPhone());
            ps.setString(6, user.getUserAddress());
            ps.setString(7, user.getUserGender());
            if (user.getUserBirth() != null) {
                ps.setDate(8, Date.valueOf(user.getUserBirth()));
            } else {
                ps.setNull(8, Types.DATE);
            }
            ps.setTimestamp(9, Timestamp.valueOf(user.getCreatedAt().atStartOfDay()));
            ps.executeUpdate();
            return true;
        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            // MySQL 1062 = Duplicate entry (진짜 아이디/이메일 중복)만 false로 처리.
            // 같은 예외 클래스로 NOT NULL 위반(1048) 등도 같이 묶여 들어오므로,
            // 에러 코드까지 확인하지 않으면 전혀 다른 문제를 "중복"이라고 오판하게 됨.
            if (e.getErrorCode() == 1062) {
                return false;
            }
            e.printStackTrace();
            throw new RuntimeException("회원가입 처리 중 오류: " + e.getMessage(), e);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("회원가입 처리 중 오류: " + e.getMessage(), e);
        }
    }
}
