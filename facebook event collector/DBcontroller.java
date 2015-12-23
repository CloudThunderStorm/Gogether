package facebookEventCollector;

import java.sql.*;

public class DBcontroller {
	// set mySQL DB configurations
	static final String USER = "";
	static final String PASS = "";
	static final String url = "gotogether.c1x3yqbfdy6z.us-east-1.rds.amazonaws.com:3306/GoTogether";
	static final String DB_URL = "jdbc:mysql://" + url;

	// set the format of the table
	
	static final String eventTableField = "eventId, title, description, latitude, longitude, organizerName, startTime, endTime, category, status";
	static final String eventValueField = "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	static final String insertToEvent = "INSERT INTO event (" + eventTableField + ") VALUES " + eventValueField;
	static final String insertIndex = "INSERT INTO facebookEvent (eventId) VALUES (?)";

	// JDBC connection and statement
	Connection conn;

	public void setConnnection() 
	{
		try 
		{
			System.out.println("configure JDBC driver");
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(DB_URL, USER, PASS);
		} catch (Exception e) { e.printStackTrace(); }
	}

	public void closeConnection() 
	{
		try 
		{
			conn.close();
		} catch (SQLException se) { se.printStackTrace(); }
	}

	public boolean insertEntry(long eventId, String title, String description, double latitude, double longitude,
			String organizerName, Timestamp startTime, Timestamp endTime, String category, String status) 
	{
		if(checkExsit(eventId)) return false;
		long id = findLastId() + 1;
		try 
		{
			PreparedStatement insertStmt = conn.prepareStatement(insertToEvent);	
			insertStmt.setLong(1, id);
			insertStmt.setString(2, title);
			insertStmt.setString(3, description);;
			insertStmt.setDouble(4, latitude);
			insertStmt.setDouble(5, longitude);;
			insertStmt.setString(6, organizerName);
			insertStmt.setTimestamp(7, startTime);
			insertStmt.setTimestamp(8, endTime);
			insertStmt.setString(9, category);
			insertStmt.setString(10, status);;
			insertStmt.executeUpdate();
			PreparedStatement insertIndexStmt = conn.prepareStatement(insertIndex);
			insertIndexStmt.setLong(1, eventId);
			insertIndexStmt.executeUpdate();
		} catch (SQLException e) { e.printStackTrace(); }
		return true;
	}
	
	public boolean checkExsit(long eventId) 
	{
		String checkSQL = "SELECT COUNT(eventId) AS number from facebookEvent where eventId = ?";
		try 
		{
			PreparedStatement checkStmt = conn.prepareStatement(checkSQL);	
			checkStmt.setLong(1, eventId);
			ResultSet rs = checkStmt.executeQuery();
			int count = 0;
			while(rs.next())
				count = rs.getInt("number");
			if(count > 0) return true;
		} catch (SQLException e) { e.printStackTrace(); }
		return false;
	}

	public long findLastId() 
	{
		long id = -1;
		String findEventId = "SELECT MAX(eventId) AS maxid FROM event";
		try 
		{
			PreparedStatement insertStmt = conn.prepareStatement(findEventId);
			ResultSet rs = insertStmt.executeQuery();
			while(rs.next())
				id = rs.getLong("maxid");
		} catch (SQLException e) { e.printStackTrace(); }
		return id;
	}
}
