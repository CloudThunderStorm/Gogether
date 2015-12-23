## Gogether

### Introduction
This is a location oriented social platform

### Backend
Our backend program consists of two main parts 

1. A Java servlet based on Spring MVC framework.
2. a MySQL database running on AWS RDS platform. 

The Java servlet is responsible for maintaining the database and providing RESTful service to the frontend. The frontend of our project, which consists both of the web frontend client and the iOS application, will get access to the event data in the database via this servlet. For example, the web client could retrieve the current available events according to different filters by sending an HTTP GET request to the backend servlet, the servlet will search the target events in the database and return the result to the frontend client in JSON format. 

Important files:

1. RequestController.java contains the RESTful controller source code
2. DBController.java contains all database related operations
3. Application.java is the start class for this Spring Boot application

### Style Guide
Java: [Google Java Style](https://google-styleguide.googlecode.com/svn/trunk/javaguide.html)
JavaScript: [Google JavaScript Style Guide](https://google.github.io/styleguide/javascriptguide.xml)
