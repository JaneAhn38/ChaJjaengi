package util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * 각 스팟 반경 안에 있는 유저 수를 계산해서 spot_presence 테이블에 채워 넣는다.
 * (원래 기획서에는 "MySQL Event Scheduler로 자동 집계"라고 되어 있었지만 실제로는
 * 구현되어 있지 않았음 - Aiven 무료 플랜 등 이벤트 권한이 없는 환경에서도 동일하게
 * 동작하도록 Java 쪽 스케줄러(PresenceScheduler)에서 이 SQL을 주기적으로 실행한다.)
 *
 * ST_Distance_Sphere는 두 지점 사이 거리를 미터 단위로 반환하는 표준 MySQL 8 함수라
 * 별도 권한 없이 사용 가능하다.
 */
public class PresenceAggregator {

    private static final String SQL = """
        INSERT INTO spot_presence (spot_id, active_user_count, calculated_at)
        SELECT s.spot_id,
               COUNT(DISTINCT ucl.user_id),
               NOW()
        FROM spots s
        LEFT JOIN user_current_location ucl
            ON ST_Distance_Sphere(
                   POINT(s.longitude, s.latitude),
                   POINT(ucl.current_longitude, ucl.current_latitude)
               ) <= s.radius_m
           AND ucl.updated_at >= (NOW() - INTERVAL 10 MINUTE)
        GROUP BY s.spot_id
        ON DUPLICATE KEY UPDATE
            active_user_count = VALUES(active_user_count),
            calculated_at     = VALUES(calculated_at)
        """;

    /** 한 번 집계를 실행한다. 실패해도 예외를 던지지 않고 로그만 남긴다(스케줄러가 계속 돌아야 하므로). */
    public static void runOnce() {
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            int updated = stmt.executeUpdate(SQL);
            System.out.println("PresenceAggregator: " + updated + "개 스팟 인원 집계 완료");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
