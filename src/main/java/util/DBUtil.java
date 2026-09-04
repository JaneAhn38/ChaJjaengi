package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    // DB 접속 정보는 시스템 프로퍼티(-D) 또는 환경변수로 주입합니다 (DB_URL / DB_USER / DB_PASSWORD).
    // 미설정 시 로컬 개발용 기본값(local MySQL, AnyoneHereDB)으로 폴백합니다.
    private static final String URL = env("DB_URL", "jdbc:mysql://localhost:3306/AnyoneHereDB");
    private static final String USER = env("DB_USER", "root");
    private static final String PASSWORD = env("DB_PASSWORD", "1234");

    private static String env(String key, String fallback) {
        String prop = System.getProperty(key);
        if (prop != null && !prop.isBlank()) return prop;
        String value = System.getenv(key);
        return (value != null && !value.isBlank()) ? value : fallback;
    }

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // MySQL 8버전 기준
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
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