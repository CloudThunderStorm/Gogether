package backend;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

public class EventRowMapper implements RowMapper<Event>
{
	public Event mapRow(ResultSet rs, int rowNum) throws SQLException
	{
		Event event = new Event();
		
		event.setEventId(rs.getLong("eventId"));
		event.setTitle(rs.getString("title"));
		event.setDescription(rs.getString("description"));
		event.setLatitude(rs.getDouble("latitude"));
		event.setLongitude(rs.getDouble("longitude"));
		event.setOrganizerName(rs.getString("organizerName"));
		event.setTime(rs.getTimestamp("startTime"), rs.getTimestamp("endTime"));
		event.setStatus(rs.getString("status"));
		event.setCategory(rs.getString("category"));
		
		return event;
	}
}
