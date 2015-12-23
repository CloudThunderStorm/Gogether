package backend;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.springframework.jdbc.core.RowMapper;

public class UserRowMapper implements RowMapper<User>
{
	public User mapRow(ResultSet rs, int rowNum) throws SQLException
	{
		User user = new User();
		
		user.setUserId(rs.getLong("userId"));
		user.setName(rs.getString("userName"));
		user.setDescription(rs.getString("description"));
		user.setBioImageURL(rs.getString("bioImageURL"));
		user.setPassword(rs.getString("userpassword"));
		
		return user;
	}
}
