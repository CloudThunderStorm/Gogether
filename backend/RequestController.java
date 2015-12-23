package backend;

import java.util.Date;
import java.util.List;


import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin
@RestController
public class RequestController 
{
    private DBController controller;
    
    @RequestMapping(value = "/test", method = RequestMethod.GET)
    public Response test(@RequestParam(value="message", defaultValue="") String message)
    {
    	System.out.println(message);
    	return new Response("received :" + message);
    }
    
    @RequestMapping(value = "/addUser", method = RequestMethod.POST)
    public Response addUser(@RequestBody User newUser)
    {
    	long tempId = controller.findLatestId(true);
    	newUser.setUserId(tempId + 1);
    	if(!controller.createNewUser(newUser))
    		return new Response("failed");
    	return new Response("success");
    }
    
    @RequestMapping(value = "/addEventByMobile", method = RequestMethod.POST)
    public String addEventByMobile(@RequestBody Event newEvent)
    {
    	long tempId = controller.findLatestId(false);
    	newEvent.setEventId(tempId + 1);
    	newEvent.setStatus("active");
    	if(controller.createNewEvent(newEvent))
    		return "" + (tempId + 1);
    	return "-1";
    }
    
    @RequestMapping(value = "/addEvent", method = RequestMethod.POST)
    public Response addEevnt(@RequestBody Event newEvent)
    {
    	long tempId = controller.findLatestId(false);
    	newEvent.setEventId(tempId + 1);
    	newEvent.setStatus("active");
    	if(controller.createNewEvent(newEvent))
    		return new Response("success");
    	return new Response("failed");
    }
    
    @RequestMapping(value = {"/findEventByUser", "/findEventByUserMobile"}, method = RequestMethod.GET)
    public List<Event> findEventByUserId(@RequestParam(value="userName", defaultValue="userName") String userName)
    {
    	List<Event> eventList = controller.findEventByUser(userName);
    	return eventList;
    }
    
    @RequestMapping(value = "/findOrganizedEvent", method = RequestMethod.GET)
    public List<Event> findOrganizedEvent(@RequestParam(value="userName", defaultValue="userName") String userName)
    {
    	return controller.findOrganizedEvent(userName);
    }
    
    @RequestMapping(value = "/findFollowingEvent", method = RequestMethod.GET)
    public List<Event> findFollowingEvent(@RequestParam(value="userName", defaultValue="userName") String userName)
    {
    	return controller.findFollowingEvent(userName);
    }
    
    @RequestMapping(value = "/findUserByEvent", method = RequestMethod.GET)
    public List<String> findUserByEvent(@RequestParam(value="eventId", defaultValue="1") long eventId)
    {
    	List<String> userList = controller.findUserByEvent(eventId);
    	return userList;
    }
    
    @RequestMapping(value = "/findUserByEventMobile", method = RequestMethod.GET)
    public List<Follower> findUserByEventMobile(@RequestParam(value="eventId", defaultValue="1") long eventId)
    {
    	List<Follower> userList = controller.findUserByEventMobile(eventId);
    	return userList;
    }
    
    @RequestMapping(value = {"/followEvent", "/followEventMobile"}, method = RequestMethod.GET)
    public Response followEvent(@RequestParam(value="userName", defaultValue="userName") String userName,
    							@RequestParam(value="eventId", defaultValue="1") long eventId)
    {
    	if(controller.bindUserWithEvent(eventId, userName))
    		return new Response("success");
    	return new Response("failed");
    }
    
    @RequestMapping(value = "/unfollow", method = RequestMethod.GET)
    public Response unfollow(@RequestParam(value="userName", defaultValue="userName") String userName,
    						 @RequestParam(value="eventId", defaultValue="1") long eventId)
    {
    	if(controller.unfollow(userName, eventId))
    		return new Response("success");
    	return new Response("failed");
    }
    
    @RequestMapping(value = {"/deleteEvent", "/deleteEventByMobile"}, method = RequestMethod.GET)
    public Response deleteEvent(@RequestParam(value="eventId", defaultValue="1") long eventId,
    							@RequestParam(value="organizerName", defaultValue="name") String organizerName)
    {
    	controller.deleteEvent(eventId);
    	return new Response("success");
    }
    
    @RequestMapping(value = {"/mobileLogin", "/login"}, method = RequestMethod.GET)
    public LoginResponse MobileLogin(@RequestParam(value="userName", defaultValue="") String userName,
    							@RequestParam(value="password", defaultValue="") String password)
	{
    	LoginResponse res = new LoginResponse();
    	if(controller.userLogin(userName, password, res))
    		res.setResponse("success");
    	else
    		res.setResponse("failed");
    	return res;
	}
    
    @RequestMapping(value = "/findAllEvent", method = RequestMethod.GET)
    public List<Event> findAllEvents()
    {
    	return controller.findAllEvent();
    }
    
    @RequestMapping(value = "/searchEvent", method = RequestMethod.GET)
    public @ResponseBody List<Event> searchEvent(@RequestParam(value="top", defaultValue="100") double top,
    										  	 @RequestParam(value="left", defaultValue="100") double left,
    										  	 @RequestParam(value="bottom", defaultValue="100") double bottom,
    										  	 @RequestParam(value="right", defaultValue="100") double right,
    										  	 @RequestParam(value="timeslot", defaultValue="336") long slot,
    										  	 @RequestParam(value="currentTime", defaultValue="-1") long currentTime,
    										  	 @RequestParam(value="category", defaultValue="all") String category)
    {
    	//System.out.println("" + top + " " + left + " " + bottom + " " + right);
    	//System.out.println("" + slot + " " + category);
    	java.sql.Timestamp start, end;
    	start = uDateToSDate(new Date(currentTime));
    	
    	end = uDateToSDate(new Date(currentTime + slot * 60 * 60 * 1000 + 1));
    	//System.out.println(start);
    	//System.out.println(end);
    	List<Event> eventList = controller.serchEvent(top, left, bottom, right, start, end, category);
    	return eventList;
    }
      
    public RequestController()
    {
    	/*
    	ApplicationContext context = new ClassPathXmlApplicationContext("Beans.xml");
    	controller = (DBController)context.getBean("dbController");
    	((ClassPathXmlApplicationContext)context).close();
    	*/
    	controller = new DBController();
    }
        
    private static java.sql.Timestamp uDateToSDate(java.util.Date uDate) {
		java.sql.Timestamp sDate = new java.sql.Timestamp(uDate.getTime());
		return sDate;
	}
}
