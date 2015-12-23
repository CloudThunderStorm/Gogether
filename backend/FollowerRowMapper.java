package backend;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

public class FollowerRowMapper implements RowMapper<Follower>
{
	public Follower mapRow(ResultSet rs, int rowNum) throws SQLException
	{
		Follower follower = new Follower();
		
		follower.setUserName(rs.getString("userName"));
		
		
		return follower;
	}
}
