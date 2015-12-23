package backend;

public class User 
{
	private String name;
	private long userId;
	private String description;
	private String bioImageURL;
	private String password;
	
	public User(String name, long userId, String description, String bioImageURL, String password)
	{
		this.name = name;
		this.userId = userId;
		this.description = description;
		this.bioImageURL = bioImageURL;
		this.password = password;
	}
	
	public User()
	{
		
	}
	
	public String getPassword() 
	{
		return password;
	}

	public void setPassword(String password) 
	{
		this.password = password;
	}
	
	public String getName()
	{
		return this.name;
	}
	
	public int getUserId()
	{
		return (int)this.userId;
	}
	
	public String getDescription()
	{
		return description;
	}
	
	public String getBioImageURL()
	{
		return bioImageURL;
	}
	
	public void setName(String name) 
	{
		this.name = name;
	}

	public void setUserId(long userId) 
	{
		this.userId = userId;
	}

	public void setDescription(String description) 
	{
		this.description = description;
	}

	public void setBioImageURL(String bioImageURL) 
	{
		this.bioImageURL = bioImageURL;
	}
}
