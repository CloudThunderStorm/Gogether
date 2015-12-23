## Gogether

### Introduction
Gogether is a cross platfom social events sharing Application. In this project, we developed a web application and an iOS application to allow users to find, create and manage events in our system. our back-end server continuously grasps social events from Facebook Graph APIs and manages the requests from Gogether users using RDS MySQL database. Both back-end server and HTTP server is deployed on AWS.

### Backend (backend)
Our backend program consists of two main parts:

1. A Java servlet based on Spring MVC framework.
2. a MySQL database running on AWS RDS platform.

The Java servlet is responsible for maintaining the database and providing RESTful service to the front-end. The front-end of our project, which consists both of the web front-end client and the iOS application, will get access to the event data in the database via this servlet. For example, the web client could retrieve the current available events according to different filters by sending an HTTP GET request to the backend servlet, the servlet will search the target events in the database and return the result to the front-end client in JSON format.

Important files:

1. RequestController.java contains the RESTful controller source code
2. DBController.java contains all database related operations
3. Application.java is the start class for this Spring Boot application

### Web Application (gogether)
Web server is built based on Python with Flask web development. Flask has two main dependencies. The routing, debugging, and Web Server Gateway Interface (WSGI) subsystems come from Werkzeug, while template support is provided by Jinja2.

### iOS Application (iOS application)
iOS application is built with Swift programming.

### Facebook Event Collector (facebook event collector)
Facebook Graph API is the primary way to get data in and out of Facebook's platform. It's a low-level HTTP-based API that you can use to query data, post new stories, manage ads, upload photos and a variety of other tasks that an app might need to do.

### Style Guide
1. Java: [Google Java Style](https://google-styleguide.googlecode.com/svn/trunk/javaguide.html)
2. JavaScript: [Google JavaScript Style Guide](https://google.github.io/styleguide/javascriptguide.xml)
