package facebookEventCollector;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ListIterator;
import java.sql.Timestamp;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class HttpFetchFB 
{
	public static void main(String[] args) 
	{
		String MY_ACCESS_TOKEN = "CAACEdEose0cBAOdF7uHgFZCCz6dKjhz49Dgc6oSpB0XVE1JxE8tcsVibZA7ZBiS9KOmGmtjP6hGxkcgfckfxTNI5XZCqZARV6PUmBDo8LLwT6fnvXsknea2rHEpA8HfQlnwph4mnAj5e8BhKHW0BTUGyZAMvWodvImlfvz0vwvTcXOuvB1nai6WyZCE4On4p2Lc1Jzk9sM5TgZDZD";
		String query = "https://graph.facebook.com/v2.5/search?q=newyork&since=" 
						+ String.valueOf(System.currentTimeMillis() / 1000) 
						+ "&type=event&access_token="
						+ MY_ACCESS_TOKEN;
		DBcontroller db = new DBcontroller();
		db.setConnnection();
		JSONParser parser = new JSONParser();
		JSONObject jsonUserData;
		
		int count = 0;
		
		try 
		{
			while(query != null)
			{
				Thread.sleep(10000);
				URL url = new URL(query);
				HttpURLConnection con = (HttpURLConnection) url.openConnection();
				con.setRequestMethod("GET");
				
				BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
				String inputLine;
				StringBuffer response = new StringBuffer();
	
				while ((inputLine = in.readLine()) != null) 
					response.append(inputLine);
				
				in.close();
				jsonUserData = (JSONObject)parser.parse(response.toString());
				JSONArray data = (JSONArray) jsonUserData.get("data");
				ListIterator<?> it = data.listIterator();
				
				while(it.hasNext())
				{
					JSONObject obj = (JSONObject) it.next();
					double latitude = 0.0;
					double longitude = 0.0;
					JSONObject place = (JSONObject) obj.get("place");
					if(place != null)
					{	
						JSONObject location = (JSONObject) place.get("location");
						if(location != null)
						{	
							if(location.get("longitude") != null && location.get("latitude") != null)
							{
								longitude = Double.parseDouble(String.valueOf(location.get("longitude")));
								latitude = Double.parseDouble(String.valueOf(location.get("latitude")));		
							}
							else 
								continue;
						}
						else 
							continue;
					}
					else 
						continue;
					long eventId = Long.parseLong((String)obj.get("id"));
					String title = (String) obj.get("name");
					String description = (String) obj.get("description");
					String organizerName = "facebook";
					Timestamp startTime = convertToSqlTime((String)obj.get("start_time"));
					Timestamp endTime = convertToSqlTime((String)obj.get("end_time"));
					if(endTime == null)
						endTime = startTime;
					String category = "facebook";
					String status = "active";
					if(description!= null && description.length() > 100)
						description = description.substring(0, 99);
					if(description == null)
						description = "";
					db.insertEntry(eventId, title, description, latitude, longitude, 
							organizerName, startTime, endTime, category, status);
					System.out.println(obj);
					count++;
				}
				//System.out.println(count);

				JSONObject paging = (JSONObject) jsonUserData.get("paging");
				if(paging == null) break;
				if(paging.get("next") == null) break;
				query = (String) paging.get("next");
			}
		} 
		catch (ParseException e) { e.printStackTrace();} 
		catch (MalformedURLException e) { e.printStackTrace();} 
		catch (IOException e) { e.printStackTrace(); } 
		catch (Exception e) { e.printStackTrace(); }
		
		System.out.println(count);

	}

	private static Timestamp convertToSqlTime(String timestamp) 
	{
		if(timestamp == null) return null;
		String[] paras = timestamp.split("[:T]");
		
		String time = paras[0] + " " + paras[1] + ":" + paras[2] + ":" + paras[3];
		SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		Timestamp sqlTime = null;
		try 
		{
			sqlTime = new Timestamp(format.parse(time).getTime());
		} catch (java.text.ParseException e) { e.printStackTrace(); }
		return sqlTime;
	}

}
