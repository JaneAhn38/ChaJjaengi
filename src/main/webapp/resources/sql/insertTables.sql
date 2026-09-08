SHOW TABLE STATUS;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS wishlist, reviews, spot_presence, location_logs,
    profile, user_cars, user_privacy_setting, spots, users, add_spot_applications,
    user_current_location, spot_category, remove_spot_applications,
    post_images, post_reports, post_likes, post_comments, posts;


SET FOREIGN_KEY_CHECKS = 1;
-- 유저
CREATE TABLE users
(
    user_id       VARCHAR(30)  NOT NULL,               -- PK: 유저 아이디
    user_email    VARCHAR(100) NOT NULL UNIQUE,        -- 유저 이메일
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 가입일자
    user_password VARCHAR(255) NOT NULL,               -- 비밀번호
    user_name     VARCHAR(10)  NOT NULL,               -- 사용자 이름
    user_gender   VARCHAR(4),                          -- 성별
    user_birth    DATE,                                -- 생년월일
    user_phone    VARCHAR(20),                         -- 연락처
    user_address  VARCHAR(100),                        -- 주소
    user_role     VARCHAR(10) DEFAULT 'USER',          -- 권한 (USER / ADMIN)

    PRIMARY KEY (user_id)
) DEFAULT CHARSET = utf8mb4;


-- 유저 프로필
CREATE TABLE profile
(
    user_id       VARCHAR(30),  -- PK, FK: 유저 아이디
    description   TEXT,         -- 내 소개
    profile_image VARCHAR(100), -- 프로필 사진
    -- 2/10 추가!!!!!!!!!!!!!!!!!!!!!!!!
    nickname      VARCHAR(10) UNIQUE,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;

-- 차량 정보 (유저당 여러 대 등록 가능)
CREATE TABLE user_cars
(
    car_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id     VARCHAR(30)  NOT NULL,
    car_brand   VARCHAR(30),           -- 제조사 (현대, 기아 등)
    car_model   VARCHAR(30),           -- 모델명 (아반떼, K5 등)
    car_year    INT,                   -- 연식
    car_image   VARCHAR(100),          -- 차량 사진
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;

-- 사용자의 위치 로그 원본 데이터 (집계 전 raw 데이터)
CREATE TABLE location_logs
(
    log_id    INT AUTO_INCREMENT NOT NULL, -- PK: 로그 고유 ID
    user_id   VARCHAR(30)        NOT NULL, -- FK: 유저 ID
    latitude  DECIMAL(10, 7),              -- 유저 위도
    longitude DECIMAL(10, 7),              -- 유저 경도
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (log_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE

) DEFAULT CHARSET = utf8mb4;

-- 2/10 추가!!!!!!!!!!!!!!
CREATE TABLE spot_category
(
    category_id   INT NOT NULL,
    category_name VARCHAR(20),

    PRIMARY KEY (category_id)
) DEFAULT CHARSET = utf8mb4;

INSERT INTO spot_category (category_id, category_name) VALUES
(1, 'cafe'),
(2, 'park'),
(3, 'dining'),
(4, 'hobby'),
(5, '문화/공연');


-- 드라이브 스팟 정보
CREATE TABLE spots
(
    spot_id          INT AUTO_INCREMENT NOT NULL, -- PK: 장소 고유 ID
    spot_name        VARCHAR(50)        NOT NULL, -- 장소 이름
    latitude         DECIMAL(10, 7),              -- 장소 위도
    longitude        DECIMAL(10, 7),              -- 장소 경도
    radius_m         DOUBLE,                      -- 주변인 계산 위한 장소 범위
    spot_description TEXT,                        -- 장소 설명
    -- 2/10 추가!!!!!!!!!!!!!!!!!!!!!!!!
    spot_image       VARCHAR(100),                -- 장소 사진
    spot_category    INT                NOT NULL,

    PRIMARY KEY (spot_id),
    FOREIGN KEY (spot_category) REFERENCES spot_category (category_id) ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;

-- 특정 스팟에 현재 존재하는 사용자 수에 대한 집계 결과
CREATE TABLE spot_presence
(
    spot_id           INT NOT NULL,                        -- PK, FK: 장소 고유 ID
    active_user_count INT       DEFAULT 0,                 -- 존재하는 유저 수
    calculated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 계산된 시간

    PRIMARY KEY (spot_id),
    FOREIGN KEY (spot_id) REFERENCES spots (spot_id) ON DELETE CASCADE

) DEFAULT CHARSET = utf8mb4;

-- 유저 노출/프라이버시 정책
CREATE TABLE user_privacy_setting
(
    user_id             VARCHAR(30) NOT NULL,  -- PK, FK: 유저 고유 ID
    show_location_onOff BOOLEAN DEFAULT FALSE, -- 위치 노출 여부

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE

) DEFAULT CHARSET = utf8mb4;

-- 스팟 후기
CREATE TABLE reviews
(
    review_id         INT AUTO_INCREMENT NOT NULL,         -- PK: 리뷰 고유 ID
    user_id           VARCHAR(30)        NOT NULL,         -- FK: 리뷰 작성한 유저 ID
    spot_id           INT                NOT NULL,         -- FK: 장소 ID
    review_text       TEXT,                                -- 리뷰 내용
    review_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 작성시간
    review_rating     DOUBLE,                              -- 별점

    PRIMARY KEY (review_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (spot_id) REFERENCES spots (spot_id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_review (user_id, spot_id)

) DEFAULT CHARSET = utf8mb4;


-- 스팟 찜 리스트
CREATE TABLE wishlist
(
    user_id             VARCHAR(30)        NOT NULL, -- PK, FK: 유저 ID
    spot_id             INT                NOT NULL, -- PK, FK: 장소 ID
    -- 2/10 추가 !!!!!!!!!!!!!!!!!
    wishlist_id         INT AUTO_INCREMENT NOT NULL,
    wishlist_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (wishlist_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (spot_id) REFERENCES spots (spot_id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_review (user_id, spot_id)

) DEFAULT CHARSET = utf8mb4;

-- 스팟 추가 요청
CREATE TABLE add_spot_applications
(
    add_application_id  INT AUTO_INCREMENT NOT NULL,           -- PK: 신청서 고유 ID
    user_id             VARCHAR(30)        NOT NULL,           -- FK: 유저 ID
    spot_name           VARCHAR(20)        NOT NULL,           -- 추가할 장소명
    spot_latitude       DECIMAL(10, 7),                        -- 추가할 장소 위도
    spot_longitude      DECIMAL(10, 7),                        -- 추가할 장소 위치
    spot_description    VARCHAR(500)       NOT NULL,           -- 장소 설명
    add_status          VARCHAR(20) DEFAULT 'PENDING',         -- 승인 여부
    add_spot_created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP, -- 폼 제출 일자
    spot_category       VARCHAR(20) DEFAULT 'cafe',            -- 장소 카테고리
    application_reason  VARCHAR(500) NOT NULL DEFAULT '',      -- 등록 신청 이유
    spot_image          VARCHAR(100),                          -- 장소 사진
    added_spot_address  VARCHAR(100),                          -- 장소 주소
    reject_reason       VARCHAR(300),                          -- 거절 사유

    PRIMARY KEY (add_application_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CHECK (add_status IN ('PENDING', 'APPROVED', 'REJECTED'))

) DEFAULT CHARSET = utf8mb4;

-- 2/25 추가
CREATE TABLE remove_spot_applications
(
    remove_application_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id                VARCHAR(30)  NOT NULL,
    spot_id                INT          NOT NULL,
    remove_reason          VARCHAR(300) NOT NULL,
    remove_status          VARCHAR(20) DEFAULT 'PENDING',
    remove_spot_created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    reject_reason          VARCHAR(300),                          -- 거절 사유

    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (spot_id) REFERENCES spots (spot_id) ON DELETE CASCADE,
    CHECK (remove_status IN ('PENDING', 'APPROVED', 'REJECTED'))
) DEFAULT CHARSET = utf8mb4;
-- 2/10 추가!!!!!!!!!!!!!!!!!!!!!!!!
CREATE TABLE user_current_location
(
    user_id           VARCHAR(30) NOT NULL, -- FK: 유저 ID
    current_latitude  DECIMAL(10, 7),
    current_longitude DECIMAL(10, 7),
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;


-- 추후 추가 기능 관련 table
CREATE TABLE posts
(
    post_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id    VARCHAR(30)  NOT NULL,
    category   VARCHAR(20)  NOT NULL,              -- FREE, REVIEW, QUESTION, RECOMMEND
    title      VARCHAR(100) NOT NULL,
    content    TEXT         NOT NULL,
    view_count INT       DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted BOOLEAN   DEFAULT FALSE,

    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    CHECK (category IN ('FREE', 'REVIEW', 'QUESTION', 'RECOMMEND'))
) DEFAULT CHARSET = utf8mb4;

-- 게시글 첨부 이미지
CREATE TABLE post_images
(
    image_id   INT AUTO_INCREMENT PRIMARY KEY,
    post_id    INT          NOT NULL,
    image_path VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,

    FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;

-- 댓글
CREATE TABLE post_comments
(
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id    INT         NOT NULL,
    user_id    VARCHAR(30) NOT NULL,
    content    TEXT        NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN   DEFAULT FALSE,

    FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) DEFAULT CHARSET = utf8mb4;

-- 좋아요
CREATE TABLE post_likes
(
    like_id    INT AUTO_INCREMENT PRIMARY KEY,
    post_id    INT         NOT NULL,
    user_id    VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    UNIQUE KEY uk_post_like (post_id, user_id)
) DEFAULT CHARSET = utf8mb4;

-- 게시글 신고
CREATE TABLE post_reports
(
    report_id     INT AUTO_INCREMENT PRIMARY KEY,
    post_id       INT          NOT NULL,
    reporter_id   VARCHAR(30)  NOT NULL,
    reason        VARCHAR(300) NOT NULL,
    report_status VARCHAR(20) DEFAULT 'PENDING',
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
    FOREIGN KEY (reporter_id) REFERENCES users (user_id) ON DELETE CASCADE,
    UNIQUE KEY uk_post_reporter (post_id, reporter_id),
    CHECK (report_status IN ('PENDING', 'REVIEWED', 'DISMISSED'))
) DEFAULT CHARSET = utf8mb4;
