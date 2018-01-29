# engineering-reviews-manager

### Introduction
Engineering-Review-Manager is an internal application used to submit a review summary by one who has participated in a review. A review that is submitted through this application is stored in a database and an email summarizing the review is sent to the relevant parties. These parties include the reporter, contributors, participants, Eng.team and the team that the component which was reviewed belongs to.

### Structure and Development.
The technologies used to implement the client side were jaggery.js, JavaScript, HTML and CSS while those used to implement the server side was Ballerina version 0.91. This application employees two separate databases of which one belongs to the WSO2 Product Quality Dashboard in order to hire WSO2 team details and WSO2 product details and the other is used solely to this app(this internal schema is available in the DB folder).

Config.json file inside the services folder contains the configuration data for two databases and the Gmail connector. Following configuration details should be customized by user as required.

{ "sql" :{
      "jdbcURL":"",
      "username": "",
      "password": "",
      "PQD_jdbcURL":"",
      "PQD_username": "",
      "PQD_password": ""
        },

  "gmail":{
    "recipientEmail":"",
    "userId":"",
    "accessToken":"",
    "refreshToken":"",
    "clientId":"",
    "clientSecret":""
  }
}


