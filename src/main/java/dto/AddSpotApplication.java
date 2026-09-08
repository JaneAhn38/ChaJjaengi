package dto;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class AddSpotApplication implements Serializable{
    private int applicationId; // application_id
    private String userId; // user_id
    private String spotName;
    private double spotLatitude;         // spot_latitude
    private double spotLongitude;         // spot_longitude
    private String spotDescription;        // spot_description
    private String status;    // add_spot_application_status
    private LocalDateTime createdAt;  // add_spot_created_at
    private String spotCategory;      // spot_category
    private String spotImage;         // spot_image
    private String spotAddress;       // added_spot_address
    private String rejectReason;      // reject_reason
    private String applicationReason; // application_reason

    public String getApplicationReason() { return applicationReason; }
    public void setApplicationReason(String applicationReason) { this.applicationReason = applicationReason; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public int getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(int applicationId) {
        this.applicationId = applicationId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSpotDescription() {
        return spotDescription;
    }

    public void setSpotDescription(String spotDescription) {
        this.spotDescription = spotDescription;
    }

    public double getSpotLongitude() {
        return spotLongitude;
    }

    public void setSpotLongitude(double spotLongitude) {
        this.spotLongitude = spotLongitude;
    }

    public double getSpotLatitude() {
        return spotLatitude;
    }

    public void setSpotLatitude(double spotLatitude) {
        this.spotLatitude = spotLatitude;
    }

    public String getSpotName() {
        return spotName;
    }

    public void setSpotName(String spotName) {
        this.spotName = spotName;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getSpotCategory() {
        return spotCategory;
    }

    public void setSpotCategory(String spotCategory) {
        this.spotCategory = spotCategory;
    }

    public String getSpotImage() {
        return spotImage;
    }

    public void setSpotImage(String spotImage) {
        this.spotImage = spotImage;
    }

    public String getSpotAddress() {
        return spotAddress;
    }

    public void setSpotAddress(String spotAddress) {
        this.spotAddress = spotAddress;
    }

    public AddSpotApplication() {}
}
