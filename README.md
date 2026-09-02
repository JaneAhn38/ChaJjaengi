 AnyoneHere

  자차를 가진 사람들을 위한 드라이브 스팟 공유 +
  커뮤니티 웹 서비스

  ---
  프로젝트 소개

  드라이브하기 좋은 장소(스팟)를 유저들이 직접
  발굴하고 공유하는 플랫폼입니다.
  스팟별 리뷰·별점·찜 기능과 자유롭게 소통할 수
  있는 커뮤니티 게시판을 제공합니다.
  추후 실시간 위치 기반으로 특정 스팟에 현재 몇
  명이 있는지, 어떤 차량의 소유자가 있는지
  확인하는 기능을 연동할 예정입니다.

  ---
  개발자

  1인 개발 (기획 · 백엔드 · 프론트엔드 · 데이터 전체 담당)

  ---
  기술 스택

  ┌──────────┬─────────────────────────────────┐
  │   분류   │            사용 기술            │
  ├──────────┼─────────────────────────────────┤
  │ Language │ Java 17                         │
  ├──────────┼─────────────────────────────────┤
  │ Backend  │ Jakarta Servlet 6.0, JSP        │
  ├──────────┼─────────────────────────────────┤
  │ Frontend │ Bootstrap 5, JavaScript         │
  │          │ (Vanilla)                       │
  ├──────────┼─────────────────────────────────┤
  │ Database │ MySQL 8                         │
  ├──────────┼─────────────────────────────────┤
  │ Server   │ Apache Tomcat 10                │
  ├──────────┼─────────────────────────────────┤
  │ IDE      │ IntelliJ IDEA                   │
  └──────────┴─────────────────────────────────┘

  ---
  주요 기능

  회원

  - 회원가입 / 로그인 / 로그아웃 / 정보수정 / 탈퇴
  - 비밀번호 PBKDF2 해싱 저장
  - 권한 구분: USER / ADMIN

  프로필 & 차량

  - 닉네임, 자기소개, 프로필 사진 등록 및 수정
  - 차량 여러 대 등록/삭제 (제조사, 모델명, 연식,
  차량 사진)

  드라이브 스팟

  - 스팟 목록 조회 및 상세 페이지
  - 카테고리: 카페/음식점, 공원/자연, 쇼핑,
  관광/랜드마크, 문화/공연
  - 스팟 찜(위시리스트) 기능
  - 스팟별 리뷰 + 별점 작성/삭제

  스팟 신청 시스템

  - 유저가 스팟 추가/삭제 신청 → 관리자 승인·거절
  - 내 신청 내역 및 처리 상태 확인 (검토 중 / 승인
   / 거절)

  커뮤니티 게시판

  - 카테고리: 자유 / 드라이브 후기 / 질문 / 추천
  - 게시글 작성(이미지 다중 첨부) / 수정 / 삭제
  - 좋아요 (AJAX, 새로고침 없이 즉시 반영)
  - 댓글 작성 / 삭제
  - 게시글 신고 (1인 1신고 제한)
  - 카테고리 필터 및 페이지네이션

  관리자

  - 스팟 추가/삭제 신청 목록 확인 및 승인·거절
  처리

  ---
  DB 구조

  users                   회원 정보
  profile                 프로필 (닉네임, 소개,
  사진)
  user_cars               차량 정보 (유저당 다중
  등록)

  spots                   드라이브 스팟
  spot_category           스팟 카테고리
  wishlist                스팟 찜 목록
  reviews                 스팟 리뷰 및 별점

  add_spot_applications   스팟 추가 신청
  remove_spot_applications 스팟 삭제 신청

  posts                   커뮤니티 게시글
  post_images             게시글 첨부 이미지
  post_comments           댓글
  post_likes              좋아요
  post_reports            게시글 신고

  user_current_location   유저 현재 위치
  location_logs           위치 로그 raw 데이터
  spot_presence           스팟별 현재 인원 집계

  ---
  실행 방법

  1. MySQL에서 DB 및 테이블 생성
  -- resources/sql/insertTables.sql 실행
  -- resources/sql/communityTables.sql 실행

  2. src/main/java/util/DBUtil.java에서 DB 접속
  정보 수정
  private static final String URL  =
  "jdbc:mysql://localhost:3306/AnyoneHereDB";
  private static final String USER = "root";
  private static final String PASSWORD =
  "your_password";

  3. Tomcat에 배포 후 실행
  4. 관리자 계정 설정 (선택)
  UPDATE users SET user_role = 'ADMIN' WHERE
  user_id = '원하는아이디';
  설정 후 로그아웃 → 재로그인 필요

  ---
  향후 계획

  - Render 배포
  - 실시간 인원수 갱신 (polling)
  - 어떤 차량 소유자가 스팟 근처에 있는지 표시
  - 모바일 앱 (React Native 또는 Flutter)
