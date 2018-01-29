package Org.wso2.internal.reviewManagement;

import ballerina.net.http;
import ballerina.lang.system;
import ballerina.data.sql;
import ballerina.lang.messages;
import ballerina.utils.logger;
import ballerina.lang.jsons;
import ballerina.lang.errors;
import ballerina.lang.files;
import ballerina.lang.blobs;

@http:configuration {basePath:"/internal/review-manager/v1.0/reviews", httpsPort: 9096, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}
service<http> reviewService {

    map propertiesMap = readSQLConfigurations(configJsonPath);
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    @http:POST {}
    @http:Path {value:"/"}
    resource recordReview (message m) {

        message response = {};
        json reviewBody = {};
        json responseBody = {error: {"status": true, "msg": "Sorry! Unable to save the review"}};
        string reporterEmail;
        string contributors;
        string participants;
        string groupEmails;
        string reviewType;
        string reviewDate;
        string reviewNotes;
        string references;
        string teamName;
        string productName;
        string productVersion;
        string componentName;
        string componentVersion;

        //get the message payload in JSON format
        reviewBody = messages:getJsonPayload(m);

        logger:info(reviewBody);

        logger:debug("extracting the message ");
        try {
            reporterEmail = jsons:getString(reviewBody, "$.Reporter");
            contributors = jsons:getString(reviewBody, "$.Contributor");
            participants = jsons:getString(reviewBody, "$.Participants");
            groupEmails = jsons:getString(reviewBody, "$.GroupEmails");
            reviewType = jsons:getString(reviewBody, "$.ReviewType");
            reviewDate = jsons:getString(reviewBody, "$.ReviewDate");
            reviewNotes = jsons:getString(reviewBody, "$.ReviewNotes");
            references = jsons:getString(reviewBody, "$.Reference");
            teamName = jsons:getString(reviewBody, "$.TeamName");
            productName = jsons:getString(reviewBody, "$.ProductName");
            productVersion = jsons:getString(reviewBody, "$.ProductVersion");
            componentName = jsons:getString(reviewBody, "$.ComponentName");
            componentVersion = jsons:getString(reviewBody, "$.ComponentVersion");


            if(reporterEmail == "" || contributors == "" || participants == "" || reviewType == "" || reviewDate == "" || reviewNotes == "" ||
               teamName == "" || productName == "" || productVersion == ""){
                logger:error("Incomplete review submission");
                messages:setJsonPayload(response, responseBody);
                reply response;
            }

        }catch (errors:Error err) {
            logger:error(err.msg);
            messages:setJsonPayload(response, responseBody);
            reply response;
        }
        logger:debug("done extracting the request message");

        response = recordReview(reporterEmail, contributors, participants, groupEmails, reviewType, reviewDate, reviewNotes, references, teamName,
                                productName, productVersion, componentName, componentVersion, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/"}
    resource getAllReviews (message m,
                            @http:QueryParam {value:"dateFrom"} string dateFrom,
                            @http:QueryParam {value:"dateTo"} string dateTo) {

        message response = getAllReviews(dateFrom, dateTo, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/{reviewID}"}
    resource ReviewsByID (message m, @http:PathParam {value:"reviewID"} string reviewID) {
        message response = getReviewById(reviewID, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"types/{typeName}"}
    resource getReviewsByType (message m,
                               @http:PathParam {value:"typeName"} string typeName,
                               @http:QueryParam {value:"dateFrom"} string dateFrom,
                               @http:QueryParam {value:"dateTo"} string dateTo) {

        message response = getReviewsByType(typeName, dateFrom, dateTo, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"teams/{teamName}"}
    resource getReviewsByTeam (message m,
                               @http:PathParam {value:"teamName"} string teamName,
                               @http:QueryParam {value:"dateFrom"} string dateFrom,
                               @http:QueryParam {value:"dateTo"} string dateTo,
                               @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response =getReviewsByTeam(teamName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"teams/{teamName}/{typeName}"}
    resource getReviewsByTeamAndType (message m,
                                      @http:PathParam {value:"teamName"} string teamName,
                                      @http:PathParam {value:"typeName"} string typeName,
                                      @http:QueryParam {value:"dateFrom"} string dateFrom,
                                      @http:QueryParam {value:"dateTo"} string dateTo,
                                      @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response = getReviewsByTeamAndType(teamName, typeName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/products/{productName}"}
    resource getReviewsByProduct (message m,
                                  @http:PathParam {value:"productName"} string productName,
                                  @http:QueryParam {value:"dateFrom"} string dateFrom,
                                  @http:QueryParam {value:"dateTo"} string dateTo,
                                  @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response = getReviewsByProduct(productName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/products/{productName}/{typeName}"}
    resource getReviewsByProductAndType (message m,
                                         @http:PathParam {value:"productName"} string productName,
                                         @http:PathParam {value:"typeName"} string typeName,
                                         @http:QueryParam {value:"dateFrom"} string dateFrom,
                                         @http:QueryParam {value:"dateTo"} string dateTo,
                                         @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response = getReviewsByProductAndType(productName, typeName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }


    @http:GET {}
    @http:Path {value:"/components/{componentName}"}
    resource getReviewsByComponent (message m,
                                    @http:PathParam {value:"componentName"} string componentName,
                                    @http:QueryParam {value:"dateFrom"} string dateFrom,
                                    @http:QueryParam {value:"dateTo"} string dateTo,
                                    @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response = getReviewsByComponent(componentName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/components/{componentName}/{typeName}"}
    resource getReviewsByComponentAndType (message m,
                                           @http:PathParam {value:"componentName"} string componentName,
                                           @http:PathParam {value:"typeName"} string typeName,
                                           @http:QueryParam {value:"dateFrom"} string dateFrom,
                                           @http:QueryParam {value:"dateTo"} string dateTo,
                                           @http:QueryParam {value:"contributor"} string contributorEmail) {

        message response = getReviewsByComponentAndType(componentName, typeName, dateFrom, dateTo, contributorEmail, dbConnector);
        reply response;
    }


    @http:GET {}
    @http:Path {value:"/contributors/{contributor}"}
    resource getReviewsByContributor (message m,
                                      @http:PathParam {value:"contributor"} string contributorEmail,
                                      @http:QueryParam {value:"dateFrom"} string dateFrom,
                                      @http:QueryParam {value:"dateTo"} string dateTo) {

        message response = getReviewsByContributor(contributorEmail, dateFrom, dateTo, dbConnector);
        reply response;
    }

    @http:GET {}
    @http:Path {value:"/contributors/{contributor}/{typeName}"}
    resource getReviewsByContributorAndType (message m,
                                             @http:PathParam {value:"contributor"} string contributorEmail,
                                             @http:PathParam {value:"typeName"} string typeName,
                                             @http:QueryParam {value:"dateFrom"} string dateFrom,
                                             @http:QueryParam {value:"dateTo"} string dateTo) {

        message response = getReviewsByContributorAndType(contributorEmail, typeName, dateFrom, dateTo, dbConnector);
        reply response;
    }


}

@http:configuration {basePath:"/internal/review-manager/v1.0/products", httpsPort: 9096, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}

service<http> productService {

    map propertiesMap = readSQLConfigurationsForPQDDatabase(configJsonPath);
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    @http:GET {}
    @http:Path {value:"/"}
    resource getProducts (message m) {
        system:println("inside the resource");
        message response = getProducts(dbConnector);
        reply response;
    }


    @http:GET {}
    @http:Path {value:"/{team}"}
    resource getProductsByTeam (message m, @http:PathParam {value:"team"} string team) {
        var teamId,_ = <int>team;
        message response = getProductsByTeam(teamId, dbConnector);
        reply response;
    }
}

@http:configuration {basePath:"/internal/review-manager/v1.0/teams", httpsPort: 9096, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}

service<http> teamService {

    map propertiesMap = readSQLConfigurationsForPQDDatabase(configJsonPath);
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    @http:GET {}
    @http:Path {value:"/"}
    resource getAllTeams (message m) {
        message response = getAllTeams(dbConnector);
        reply response;
    }

}


@http:configuration {basePath:"/internal/review-manager/v1.0/types", httpsPort: 9096, keyStoreFile: "${ballerina.home}/bre/security/wso2carbon.jks", keyStorePass: "wso2carbon", certPass: "wso2carbon"}

service<http> typeService {

    map propertiesMap = readSQLConfigurations(configJsonPath);
    sql:ClientConnector dbConnector = create sql:ClientConnector(propertiesMap);

    @http:GET {}
    @http:Path {value:"/"}
    resource getAllTypes (message m) {
        message response = getAllTypes(dbConnector);
        reply response;
    }

}



function readSQLConfigurations(string configJsonPath)(map p){

    // set the file path and open file for reading
    files:File configFile = {path: configJsonPath};
    files:open(configFile, "r");

    // read the contents of the file and close the file
    var content, numberOfBytes = files:read(configFile, 100000);
    files:close(configFile);

    // read the contents as string and then convert it to json
    string configString = blobs:toString(content, "utf-8");
    json configJson = jsons:parse(configString);

    string jdbcURL = jsons:getString(configJson,"$.sql.jdbcURL");
    string username = jsons:getString(configJson,"$.sql.username");
    string password = jsons:getString(configJson,"$.sql.password");

    map propertiesMap = {"jdbcUrl":jdbcURL, "username":username, "password":password};

    return propertiesMap;
}

function readSQLConfigurationsForPQDDatabase(string configJsonPath)(map p){

    // set the file path and open file for reading
    files:File configFile = {path: configJsonPath};
    files:open(configFile, "r");

    // read the contents of the file and close the file
    var content, numberOfBytes = files:read(configFile, 100000);
    files:close(configFile);

    // read the contents as string and then convert it to json
    string configString = blobs:toString(content, "utf-8");
    json configJson = jsons:parse(configString);

    string jdbcURL = jsons:getString(configJson,"$.sql.PQD_jdbcURL");
    string username = jsons:getString(configJson,"$.sql.PQD_username");
    string password = jsons:getString(configJson,"$.sql.PQD_password");

    map propertiesMap = {"jdbcUrl":jdbcURL, "username":username, "password":password};

    return propertiesMap;
}






