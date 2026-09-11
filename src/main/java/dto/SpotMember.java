package dto;

import java.io.Serializable;

/** 스팟에 "지금 방문 중"이면서 프로필 공개에 동의한 유저 한 명. */
public class SpotMember implements Serializable {
    private String userId;
    private String nickname;
    private String profileImage;

    public SpotMember() {}

    public SpotMember(String userId, String nickname, String profileImage) {
        this.userId = userId;
        this.nickname = nickname;
        this.profileImage = profileImage;
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }
}
