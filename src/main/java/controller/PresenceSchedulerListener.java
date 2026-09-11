package controller;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import util.PresenceAggregator;
import util.SchemaMigrationUtil;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 앱이 떠 있는 동안 2분마다 spot_presence 집계를 돌린다.
 * (Render 무료 플랜처럼 앱이 잠들면 이 스케줄러도 같이 멈추지만, 앱이 깨어있는
 * 동안에는 로컬/배포 환경 구분 없이 동일하게 동작한다.)
 */
@WebListener
public class PresenceSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        SchemaMigrationUtil.runMigrations();

        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "presence-aggregator");
            t.setDaemon(true);
            return t;
        });
        // 시작 10초 후부터, 2분 간격으로 반복
        scheduler.scheduleAtFixedRate(PresenceAggregator::runOnce, 10, 120, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) scheduler.shutdownNow();
    }
}
