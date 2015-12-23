package backend;

import java.util.Date;

public class Event {
	private String title;
	private long eventId;
	private String description;
	private double longitude;
	private double latitude;
	private String organizerName;
	private java.sql.Timestamp startTime;
	private java.sql.Timestamp endTime;
	private String category;
	private String status;

	public Event(String title, long eventId, String discription,
			double longitude, double latitude, String organizerName,
			long startTime, long endTime, String category, String status) {
		this.title = title;
		this.eventId = eventId;
		this.description = discription;
		this.longitude = longitude;
		this.latitude = latitude;
		this.organizerName = organizerName;
		this.startTime = uDateToSDate(new Date(startTime));
		this.endTime = uDateToSDate(new Date(endTime));
	}

	@Override
	public String toString() {
		return "Event [title=" + title + ", eventId=" + eventId
				+ ", discription=" + description + ", longitude=" + longitude
				+ ", latitude=" + latitude + ", organizerName=" + organizerName
				+ ", startTime=" + startTime + ", endTime=" + endTime
				+ ", category=" + category + ", status=" + status + "]";
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Event() {

	}

	public java.sql.Timestamp getStartTime() {
		return startTime;
	}

	public void setStartTime(long time) {
		this.startTime = uDateToSDate(new Date(time));
	}

	public void setTime(java.sql.Timestamp start, java.sql.Timestamp end) {
		this.startTime = start;
		this.endTime = end;
	}

	public java.sql.Timestamp getEndTime() {
		return endTime;
	}

	public void setEndTime(long time) {
		this.endTime = uDateToSDate(new Date(time));
	}

	public String getOrganizerName() {
		return organizerName;
	}

	public void setOrganizerName(String organizerName) {
		this.organizerName = organizerName;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public long getEventId() {
		return eventId;
	}

	public void setEventId(long eventId) {
		this.eventId = eventId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String discription) {
		this.description = discription;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	private static java.sql.Timestamp uDateToSDate(java.util.Date uDate) {
		java.sql.Timestamp sDate = new java.sql.Timestamp(uDate.getTime());
		return sDate;
	}
}
