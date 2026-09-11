package util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Maven/Gradle 없이 순수 소스로 배포하는 프로젝트라 별도 마이그레이션 도구가 없음.
 * 그래서 이미 운영 중인 DB(로컬/Aiven)에 새 컬럼이 필요할 때는, 서버가 뜰 때
 * ALTER TABLE을 한 번 시도하고 "이미 있음(1060)" 에러는 무시하는 식으로 자체 적용한다.
 * (신규 설치는 insertTables.sql에 이미 반영돼 있어 여기서 다시 안 만들어도 됨)
 */
public class SchemaMigrationUtil {

    private static final int ERR_DUPLICATE_COLUMN = 1060;

    public static void runMigrations() {
        addColumnIfMissing(
                "ALTER TABLE user_privacy_setting ADD COLUMN share_profile_onOff BOOLEAN NOT NULL DEFAULT FALSE"
        );
    }

    private static void addColumnIfMissing(String alterSql) {
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(alterSql);
            System.out.println("SchemaMigrationUtil: 적용됨 - " + alterSql);
        } catch (SQLException e) {
            if (e.getErrorCode() == ERR_DUPLICATE_COLUMN) {
                // 이미 컬럼이 존재함 - 정상 (이전에 이미 마이그레이션됨)
                return;
            }
            System.err.println("SchemaMigrationUtil: 마이그레이션 실패 - " + alterSql);
            e.printStackTrace();
        }
    }
}
