package util;

/**
 * 회원가입 시 입력한 주소 문자열에서 시/도 단위만 골라내어,
 * 홈화면 지도를 그 지역 중심으로 확대해서 보여주기 위한 유틸.
 * (정확한 지오코딩이 아니라 "서울시/경기도" 같은 광역 단위 판별만 함)
 */
public class RegionCenterUtil {

    public record RegionView(double lat, double lng, int zoom) {}

    private record Region(RegionView view, String... keywords) {}

    // 순서 무관 - 주소 문자열에 키워드가 포함되어 있는지로 판별
    private static final Region[] REGIONS = {
            new Region(new RegionView(37.5665, 126.9780, 11), "서울"),
            new Region(new RegionView(37.4138, 127.5183, 10), "경기"),
            new Region(new RegionView(37.4563, 126.7052, 11), "인천"),
            new Region(new RegionView(35.1796, 129.0756, 11), "부산"),
            new Region(new RegionView(35.8714, 128.6014, 11), "대구"),
            new Region(new RegionView(36.3504, 127.3845, 11), "대전"),
            new Region(new RegionView(35.1595, 126.8526, 11), "광주"),
            new Region(new RegionView(35.5384, 129.3114, 11), "울산"),
            new Region(new RegionView(36.4801, 127.2890, 12), "세종"),
            new Region(new RegionView(37.8228, 128.1555, 9), "강원"),
            new Region(new RegionView(36.8000, 127.7000, 9), "충북", "충청북도"),
            new Region(new RegionView(36.5184, 126.8000, 9), "충남", "충청남도"),
            new Region(new RegionView(35.7175, 127.1530, 9), "전북", "전라북도", "전북특별자치도"),
            new Region(new RegionView(34.8679, 126.9910, 9), "전남", "전라남도"),
            new Region(new RegionView(36.4919, 128.8889, 9), "경북", "경상북도"),
            new Region(new RegionView(35.4606, 128.2132, 9), "경남", "경상남도"),
            new Region(new RegionView(33.4996, 126.5312, 10), "제주"),
    };

    /** 주소에서 시/도를 못 찾으면 null (호출부에서 기본 넓은 화면으로 폴백) */
    public static RegionView forAddress(String address) {
        if (address == null || address.isBlank()) return null;
        for (Region region : REGIONS) {
            for (String keyword : region.keywords()) {
                if (address.contains(keyword)) return region.view();
            }
        }
        return null;
    }
}
