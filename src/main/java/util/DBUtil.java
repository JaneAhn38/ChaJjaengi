package util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DBUtil {
    // DB 접속 정보는 시스템 프로퍼티(-D) 또는 환경변수로 주입합니다 (DB_URL / DB_USER / DB_PASSWORD).
    // 미설정 시 로컬 개발용 기본값(local MySQL, AnyoneHereDB)으로 폴백합니다.
    private static final String URL = env("DB_URL", "jdbc:mysql://localhost:3306/AnyoneHereDB");
    private static final String USER = env("DB_USER", "root");
    private static final String PASSWORD = env("DB_PASSWORD", "1234");

    // 매 요청마다 새로 연결(+TLS 핸드셰이크)을 맺으면 원격 DB(특히 클라우드) 기준으로
    // 눈에 띄게 느려지므로, 커넥션 풀(HikariCP)로 연결을 재사용합니다.
    private static final HikariDataSource dataSource;

    static {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(URL);
        config.setUsername(USER);
        config.setPassword(PASSWORD);
        config.setMaximumPoolSize(5);   // 무료 티어 DB의 최대 연결 수 제한을 고려한 보수적인 값
        config.setMinimumIdle(1);       // 요청이 없을 때도 최소 1개는 미리 연결해둠 (첫 요청 지연 완화)
        config.setConnectionTimeout(10_000);
        config.setIdleTimeout(300_000);
        config.setMaxLifetime(1_800_000);
        dataSource = new HikariDataSource(config);
    }

    private static String env(String key, String fallback) {
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) return prop;
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : fallback;
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
