package backend;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

public class DBController 
{
	// SQL statement
	// userInfo table
	static final String userTableField = "userId, userName, description, bioImageURL, userPassword, status, role";
	static final String userValueField = "(?, ?, ?, ?, ?, ?, ?)";
	static final String insertToUserInof = "INSERT INTO userInfo (" + userTableField + ") VALUES " + userValueField;
	static final String checkUserExistence = "SELECT COUNT(1) FROM userInfo WHERE userName = ?";
	static final String selectPassword = "SELECT userPassword FROM userInfo WHERE userName = ?";
	static final String selectDescription = "SELECT description FROM userInfo WHERE userName = ?";
	
	// event table
	static final String eventTableField = "eventId, title, description, latitude, longitude, organizerName, startTime, endTime, category, status";
	static final String eventValueField = "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	static final String insertToEvent = "INSERT INTO event (" + eventTableField + ") VALUES " + eventValueField;
	static final String checkEventExistence = "SELECT COUNT(1) FROM event WHERE eventId = ?";
	static final String selectEventById = "SELECT " + eventTableField + " FROM event WHERE eventId = ?";
	static final String selectFollowingEvent = "SELECT * FROM event WHERE eventId = ? AND organizerName != ?";
	static final String searchEvent = "SELECT " + eventTableField + " FROM event WHERE ";
	static final String locationCondition = "latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?";
	static final String timeCondition = " AND startTime BETWEEN ? AND ?";
	static final String categoryCondition = " AND category = ?";
	static final String deleteEventSQL = "DELETE FROM event WHERE eventId = ?";
	static final String searchOrganizedEvent = "SELECT * FROM event WHERE organizerName = ?";
	
	// userEventRelation table
	static final String relationTableField = "eventId, userName";
	static final String relationValueField = "(?, ?)";
	static final String insertToRelation = "INSERT INTO userEventRelation (" + relationTableField + ") VALUES " + relationValueField;
	
	static final String selectEventIdByUser = "SELECT eventId FROM userEventRelation WHERE userName = ?";
	static final String selectUserByEvent = "SELECT userName FROM userEventRelation WHERE eventId = ?";
	static final String checkEntryExistence = "SELECT COUNT(1) FROM userEventRelation WHERE eventId = ? AND userName = ?";
	static final String unfollow = "DELETE FROM userEventRelation WHERE eventId = ? AND userName = ?";
	
	@Autowired
	private JdbcTemplate template;
	
	public DBController()
	{
		DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://");
        dataSource.setUsername("");
        dataSource.setPassword("");
		
		template = new JdbcTemplate();
		template.setDataSource(dataSource);
	}

	public boolean createNewUser(User user) 
	{
		if(checkExistence(user.getName()))
			return false;
				
		template.update(insertToUserInof, 
				user.getUserId(), user.getName(), user.getDescription(), user.getBioImageURL(), user.getPassword(), true, "user");
		
		return true;
	}
	
	public boolean createNewEvent(Event event)
	{
		if(!checkExistence(event.getOrganizerName()))
			return false;
		template.update(insertToEvent,
				event.getEventId(), event.getTitle(), event.getDescription(), event.getLatitude(),
				event.getLongitude(), event.getOrganizerName(), event.getStartTime(), event.getEndTime(),
				event.getCategory(), event.getStatus());
		bindUserWithEvent(event.getEventId(), event.getOrganizerName());
		return true;
	}
	
	public void deleteEvent(long eventId)
	{
		int numberOfEvent = template.queryForObject(checkEventExistence, new Object[] {eventId}, Integer.class);
		if(numberOfEvent == 0)
			return;
		
		template.update(deleteEventSQL, eventId);
		template.update("DELETE FROM userEventRelation WHERE eventId = ?", new Object[] {eventId});
	}
	
	public List<Event> findOrganizedEvent(String userName)
	{
		if(!checkExistence(userName))
			return new ArrayList<Event>();
		List<Event> eventList = template.query(searchOrganizedEvent, new Object[] { userName }, new EventRowMapper());
		return eventList;
	}
	
	public List<Event> findFollowingEvent(String userName)
	{
		if(!checkExistence(userName))
			return new ArrayList<Event>();
		List<Long> eventIdList = template.query(selectEventIdByUser, new Object[] { userName }, 
				new RowMapper<Long>() 
				{
					public Long mapRow(ResultSet rs, int rowNum) throws SQLException
					{
						return rs.getLong("eventId");
					}
				});
		List<Event> eventList = new ArrayList<>();
		for(long id : eventIdList)
		{
			int number = template.queryForObject("SELECT COUNT(*) FROM event WHERE eventId = ? AND organizerName != ?", 
					new Object[] {id, userName}, Integer.class);
			if(number == 0)
				continue;
			Event temp = template.queryForObject(selectFollowingEvent, new Object[] { id, userName }, new EventRowMapper());
			if(temp != null)
				eventList.add(temp);
		}
		return eventList;
	}
	
	public List<Event> findEventByUser(String userName)
	{
		List<Long> eventIdList = new ArrayList<>();
		if(!checkExistence(userName))
			return new ArrayList<Event>();
		eventIdList = template.query(selectEventIdByUser, new Object[] { userName }, 
				new RowMapper<Long>() 
				{
					public Long mapRow(ResultSet rs, int rowNum) throws SQLException
					{
						return rs.getLong("eventId");
					}
				});
		List<Event> eventList = new ArrayList<>();
		for(long id : eventIdList)
		{
			Event temp = template.queryForObject(selectEventById, new Object[] { id }, new EventRowMapper());
			eventList.add(temp);
		}
		return eventList;
	}
	
	public List<String> findUserByEvent(long eventId)
	{
		List<String> userNameList = new ArrayList<>();
		userNameList = template.query(selectUserByEvent, new Object[] { eventId }, new RowMapper<String>()
				{
					public String mapRow(ResultSet rs, int rowNum) throws SQLException
					{
						return rs.getString("userName");
					}
				});
		
		return userNameList;
	}
	
	public List<Follower> findUserByEventMobile(long eventId)
	{
		List<Follower> userList = template.query(selectUserByEvent, new Object[] { eventId }, new FollowerRowMapper());
		return userList;
	}
	
	public long findLatestId(boolean forUser)
	{
		String findUserId = "SELECT MAX(userId) FROM userInfo";
		String findEventId = "SELECT MAX(eventId) FROM event";
		long id;
		if(forUser)
		{
			int number = template.queryForObject("SELECT COUNT(*) FROM userInfo", Integer.class);
			if(number == 0)
				return 0;
			id = template.queryForObject(findUserId, long.class);
		}
		else
		{
			int number = template.queryForObject("SELECT COUNT(*) FROM event", Integer.class);
			if(number == 0)
				return 0;
			id = template.queryForObject(findEventId, long.class);
		}
		return id;
	}
	
	public boolean userLogin(String userName, String password, LoginResponse res)
	{
		if(!checkExistence(userName))
			return false;
		String tempPass = template.queryForObject(selectPassword, new Object[] {userName}, String.class);
		res.setDescription(template.queryForObject(selectDescription, new Object[] {userName}, String.class));
		if(tempPass.equals(password))
			return true;
		return false;
	}
	
	public List<Event> serchEvent(double top, double left, double bottom, double right, 
			java.sql.Timestamp start, java.sql.Timestamp end, String category)
	{
		List<Event> eventList;
		if(category.equals("all"))
		{
			eventList = template.query(searchEvent + locationCondition + timeCondition, 
					new Object[] {bottom, top, left, right, start, end}, new EventRowMapper());
		}
		else
		{
			eventList = template.query(searchEvent + locationCondition + timeCondition + categoryCondition, 
					new Object[] {bottom, top, left, right, start, end, category}, 
					new EventRowMapper());
		}
		return eventList;
	}
	
	public List<Event> findAllEvent()
	{
		List<Event> eventList = template.query("SELECT * FROM event", new Object[] {}, new EventRowMapper());
		return eventList;
	}
	
	public boolean bindUserWithEvent(long eventId, String userName)
	{
		int numberOfEvent = template.queryForObject(checkEventExistence, new Object[] {eventId}, Integer.class);
		int numberOfEntry = template.queryForObject(checkEntryExistence, new Object[] {eventId, userName}, Integer.class);
		if(!checkExistence(userName) || numberOfEvent == 0 || numberOfEntry > 0)
			return false;
		template.update(insertToRelation, eventId, userName);
		return true;
	}
	
	public boolean unfollow(String userName, long eventId)
	{
		int numberOfEvent = template.queryForObject(checkEventExistence, new Object[] {eventId}, Integer.class);
		int numberOfEntry = template.queryForObject(checkEntryExistence, new Object[] {eventId, userName}, Integer.class);
		if(!checkExistence(userName) || numberOfEvent == 0 || numberOfEntry == 0)
			return false;
		template.update(unfollow, eventId, userName);
		return true;
	}
	
	private boolean checkExistence(String userName)
	{
		return (template.queryForObject(checkUserExistence, new Object[] {userName}, Integer.class) > 0);
	}
}

