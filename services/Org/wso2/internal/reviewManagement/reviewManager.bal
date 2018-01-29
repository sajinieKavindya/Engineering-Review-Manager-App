package Org.wso2.internal.reviewManagement;

import ballerina.lang.messages;
import ballerina.data.sql;
import ballerina.lang.jsons;
import ballerina.lang.strings;
import ballerina.lang.datatables;
import org.wso2.ballerina.connectors.gmail;
import ballerina.lang.errors;
import ballerina.utils.logger;
import ballerina.doc;
import ballerina.lang.files;
import ballerina.lang.blobs;
import ballerina.net.http;


@doc:Description {value:"Review definition"}
@doc:Field {value:"component_id: id of the component in which the review belongs to"}
@doc:Field {value:"component_name: name of the component in which the review belongs to"}
@doc:Field {value:"component_version: version of the component in which the review belongs to"}
@doc:Field {value:"review_id: id of the review"}
@doc:Field {value:"reporter: reporter of the review"}
@doc:Field {value:"contributor: contributor of the review"}
@doc:Field {value:"review_type: type of the review"}
@doc:Field {value:"review_date: date of the review has been submitted"}
@doc:Field {value:"product_id: id of the product in which the review belongs to"}
@doc:Field {value:"product_name: name of the product in which the review belongs to"}
@doc:Field {value:"team_name: name of the team in which the review belongs to"}
@doc:Field {value:"product_version: version of the product in which the review belongs to"}
@doc:Field {value:"review_note: review notes submitted for the review"}
@doc:Field {value:"reference: references submitted for the review"}
struct Review {
    int review_id;
    string team_name;
    string product_version;
    string product_name;
    string component_name;
    string component_version;
    string reporter;
    string review_note;
    string reference;
    string review_date;
    string review_type;
    string participants;
    string contributor;
}


@doc:Description {value:"Contributor_email definition"}
@doc:Field {value:"contributor: email of the contributor"}
struct Contributor_email {
    string contributor;
}


@doc:Description {value:"save the review in the database. update the Reviews and Contributors tables"}
@doc:Param {value:"m: request message"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: whether the success or failed"}
function recordReview(string reporterEmail, string contributors, string participants, string groupEmails, string reviewType, string reviewDate,
                      string reviewNotes, string references, string teamName, string productName, string productVersion, string componentName,
                      string componentVersion, sql:ClientConnector dbConnector)(message msg){

    message response = {};
    json responseBody = {error: {"status": true, "msg": "Sorry! Unable to save the review"}};

    // transaction for inserting data into Reviews and Contributors tables
    transaction {
        sql:Parameter teamNamePara = {sqlType:"varchar", value:teamName};
        sql:Parameter productNamePara = {sqlType:"varchar", value:productName};
        sql:Parameter productVersionPara = {sqlType:"varchar", value:productVersion};
        sql:Parameter componentNamePara = {sqlType:"varchar", value:componentName};
        sql:Parameter componentVersionPara = {sqlType:"varchar", value:componentVersion};
        sql:Parameter reporterEmailPara = {sqlType:"varchar", value:reporterEmail};
        sql:Parameter reviewNotesPara = {sqlType:"varchar", value:reviewNotes};
        sql:Parameter referencesPara = {sqlType:"varchar", value:references};
        sql:Parameter reviewDatePara = {sqlType:"varchar", value:reviewDate};
        sql:Parameter reviewTypePara = {sqlType:"varchar", value:reviewType};
        sql:Parameter participantsEmailPara = {sqlType:"varchar", value:participants};
        sql:Parameter[] params = [];
        params = [teamNamePara, productVersionPara, productNamePara, componentNamePara, componentVersionPara,
                  reporterEmailPara, reviewNotesPara, referencesPara, reviewDatePara, reviewTypePara, participantsEmailPara];

        string [] keyColumns = [];
        string [] reviewId;
        int numOfUpdatedRows;

        logger:debug("Inserting team_name:"+teamName+", product_name:"+productName+", product_version:"+productVersion+
                     ", component_name:"+componentName+", component_version:"+componentVersion+", reporter:"+reporterEmail+
                     ", review_note:"+reviewNotes+", references:"+references+" ,review_date:"+reviewDate+
                     " ,review_type:"+reviewType+" ,participants:"+participants+" into Reviews table");

        numOfUpdatedRows, reviewId = sql:ClientConnector.updateWithGeneratedKeys(dbConnector, insertReviewQueryNew , params, keyColumns);

        logger:debug("Reviews table is updated succefully. " + numOfUpdatedRows + " rows got upadated.");

        // create an list of contributors by splitting the string of contributor's emails separated by commas.
        string[] contributorsList = strings:split(contributors, ",");
        string contributorEmail;
        int count = contributorsList.length;

        sql:Parameter reviewIdPara = {sqlType:"integer", value:reviewId[0]};
        sql:Parameter contributorPara;

        //add contributors one by one to the contributor table"
        while (count > 0) {
            contributorEmail = contributorsList[count-1];
            contributorPara = {sqlType:"varchar", value:contributorEmail};
            params = [contributorPara, reviewIdPara];

            logger:debug("Inserting contributor:"+contributorEmail+", review_id:" + reviewId[0]+" into Contributors table");

            //insert contributor with the review id to the contrinbutor table
            numOfUpdatedRows = sql:ClientConnector.update(dbConnector, insertContributorsQuery, params);

            logger:debug("Inserted contributor:"+contributorEmail+", review_id:" + reviewId[0]+" into Contributors table");

            count = count - 1;
        }
        logger:info("Status: Review is succesfully saved in the database");

    }aborted {
        //set the response body failed when the transaction is failed.
        logger:error("unable to save the review. review details: team_name:"+teamName+", product_name:"+productName+", product_version:"+productVersion+
                 ", component_name:"+componentName+", component_version:"+componentVersion+", reporter:"+reporterEmail+
                 ", contributors: "+contributors+", review_note:"+reviewNotes+", " + "references:"+references+
                 " ,review_date:"+reviewDate+" ,review_type:"+reviewType+" ,participants:"+participants);

        responseBody.error.msg = "Sorry! Unable to save the review";

    }committed {

        string sender = reporterEmail;
        string subject = "["+reviewType+"] "+componentName+" : "+componentVersion+" - "+productName+" : "+ productVersion;
        logger:debug("creating the email body");
        string body = createEmailBody( reporterEmail,  contributors, participants, groupEmails, reviewType,  reviewDate,
                                       reviewNotes,  references,  teamName, componentName, componentVersion, productName, productVersion);

        responseBody = sendEmail(contributors, sender, participants, groupEmails, subject, body, responseBody);

    }
    //Gets the message payload in string format
    messages:setJsonPayload(response, responseBody);
    return response;
}





@doc:Description {value:"get all the reviews in the database"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getAllReviews(string dateFrom, string dateTo, sql:ClientConnector dbConnector)(message msg){

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    params = [dateFromPara, dateToPara];
    datatable dt;
    try {
        logger:debug("selecting all reviews between "+dateFrom+" and "+dateTo+" from the database");
        dt = sql:ClientConnector.select(dbConnector,
                                        getAllReviewsQuery +
                                        byDateQuery, params);

        logger:info("Fetched reviews from database successfully");
        //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
        response = createResponse(dt);

    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);

    }finally {
        datatables:close(dt);
    }
    return response;
}





@doc:Description {value:"get reviews by review id"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewById(string reviewID, sql:ClientConnector dbConnector)(message msg){

    message response = {};
    datatable dt;

    sql:Parameter[] params = [];
    sql:Parameter reviewIdPara = {sqlType:"integer", value:reviewID};
    params = [reviewIdPara];

    try {
        logger:debug("selecting the review which has review id: " + reviewID);

        dt = sql:ClientConnector.select(dbConnector,
                                        getAllReviewsQuery + byReviewIdQuery, params);

        logger:info("Fetched the review from database successfully");
        //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
        response = createResponse(dt);

    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}





@doc:Description {value:"get reviews by type"}
@doc:Param {value:"typeName: review type"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByType(string typeName, string dateFrom, string dateTo, sql:ClientConnector dbConnector)(message msg){

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter typeNamePara = {sqlType:"varchar", value:typeName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};

    datatable dt;

    try {

        params = [typeNamePara, dateFromPara, dateToPara];
        dt = sql:ClientConnector.select(dbConnector,
                                        getAllReviewsQuery + byReviewTypeAndDateQuery
                                        , params);


        logger:info("Fetched the review from database successfully");
        //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
        response = createResponse(dt);

    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}





@doc:Description {value:"get reviews by team"}
@doc:Param {value:"teamName: name of the team"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByTeam(string teamName, string dateFrom, string dateTo, string contributorEmail,
                          sql:ClientConnector dbConnector)(message msg){

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter teamNamePara = {sqlType:"varchar", value:teamName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};


    datatable dt;

    try{
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [teamNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byTeamNameAndDateQuery
                                            , params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);

        }else{
            params = [teamNamePara, contributorEmailPara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byTeamNameContributorAndDateQuery, params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);
        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}







@doc:Description {value:"get reviews by team and type"}
@doc:Param {value:"teamName: name of the team"}
@doc:Param {value:"typeName: type of the review"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByTeamAndType(string teamName, string typeName, string dateFrom,
                                 string dateTo, string contributorEmail, sql:ClientConnector dbConnector)(message msg){


    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter teamNamePara = {sqlType:"varchar", value:teamName};
    sql:Parameter typeNamePara = {sqlType:"varchar", value:typeName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};

    datatable dt;

    try{
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [teamNamePara, typeNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byReviewNameTypeAndDateQuery, params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);


        }else{
            params = [teamNamePara, typeNamePara, contributorEmailPara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byReviewNameTypeContributorAndDateQuery
                                            , params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);

        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}






@doc:Description {value:"get reviews by product id"}
@doc:Param {value:"productID: id of the product"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByProduct(string productName, string dateFrom, string dateTo, string contributorEmail,
                             sql:ClientConnector dbConnector)(message msg){

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter productNamePara = {sqlType:"varchar", value:productName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};

    datatable dt;

    try{
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [productNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byProductNameAndDateQuery
                                            , params);



            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);

        }else{
            params = [productNamePara, contributorEmailPara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery +  byProductNameContributorAndDateQuery, params);

            logger:info("Fetched the review from database successfully");

            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);
        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}







@doc:Description {value:"get reviews by product and type"}
@doc:Param {value:"productID: id of the product as shown in the database"}
@doc:Param {value:"typeName: type of the review"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByProductAndType(string productName, string typeName, string dateFrom,
                                    string dateTo, string contributorEmail, sql:ClientConnector dbConnector)(message msg){



    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter productNamePara = {sqlType:"varchar", value:productName};
    sql:Parameter typeNamePara = {sqlType:"varchar", value:typeName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};

    datatable dt;

    try {
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [productNamePara, typeNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byProductNameReviewTypeAndDateQuery, params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);


        }else{
            params = [productNamePara, typeNamePara, contributorEmailPara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byProductNameReviewTypeContributorAndDateQuery
                                            , params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);

        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}







@doc:Description {value:"get reviews by component"}
@doc:Param {value:"componentID: id of the component as shown in the database"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByComponent(string componentName, string dateFrom, string dateTo, string contributorEmail,
                               sql:ClientConnector dbConnector)(message msg){

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter componentNamePara = {sqlType:"varchar", value:componentName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};

    datatable dt;

    try {
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [componentNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byComponentNameAndDateQuery
                                            , params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);


        }else{
            params = [componentNamePara, contributorEmailPara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byComponentNameContributorAndDateQuery, params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);

        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}







@doc:Description {value:"get reviews by component and type"}
@doc:Param {value:"componentID: id of the component as shown in the database"}
@doc:Param {value:"typeName: type of the review"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByComponentAndType(string componentName, string typeName, string dateFrom, string dateTo,
                                      string contributorEmail, sql:ClientConnector dbConnector)(message msg){



    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter componentNamePara = {sqlType:"varchar", value:componentName};
    sql:Parameter typeNamePara = {sqlType:"varchar", value:typeName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};

    datatable dt;

    try {
        //check whether the query parameter "contributor" is empty.
        if(contributorEmail == ""){

            params = [componentNamePara, typeNamePara, dateFromPara, dateToPara];
            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byComponentNameReviewTypeAndDateQuery, params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponse(dt);


        }else{
            params = [componentNamePara, typeNamePara, contributorEmailPara, dateFromPara, dateToPara];

            dt = sql:ClientConnector.select(dbConnector,
                                            getAllReviewsQuery + byComponentNameReviewTypeContributorAndDateQuery
                                            , params);

            logger:info("Fetched the review from database successfully");
            //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
            response = createResponseFilteredByContributor(dt, dbConnector);

        }


    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}






@doc:Description {value:"get reviews by contributor"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByContributor(string contributorEmail, string dateFrom, string dateTo,
                                 sql:ClientConnector dbConnector)(message){

    message response = {};


    sql:Parameter[] params = [];
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    params = [contributorEmailPara, dateFromPara, dateToPara];
    datatable dt;

    try{

        dt = sql:ClientConnector.select(dbConnector,
                                        getAllReviewsQuery + byContributorAndDateQuery, params);

        logger:info("Fetched the review from database successfully");
        //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
        response = createResponseFilteredByContributor(dt, dbConnector);

    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;

}






@doc:Description {value:"get reviews by contributor and type"}
@doc:Param {value:"contributorEmail: email of the contributor"}
@doc:Param {value:"typeName: type of the review"}
@doc:Param {value:"dateFrom: lower bound of the reviewed date"}
@doc:Param {value:"dateTo: upper bound of the reviewed date"}
@doc:Param {value:"dbConnector: sql client connector"}
@doc:Return {value:"msg: response"}
function getReviewsByContributorAndType (string contributorEmail, string typeName, string dateFrom, string dateTo, sql:ClientConnector dbConnector) (message msg) {

    message response = {};

    sql:Parameter[] params = [];
    sql:Parameter contributorEmailPara = {sqlType:"varchar", value:"%"+contributorEmail+"%"};
    sql:Parameter typeNamePara = {sqlType:"varchar", value:typeName};
    sql:Parameter dateFromPara = {sqlType:"varchar", value:dateFrom};
    sql:Parameter dateToPara = {sqlType:"varchar", value:dateTo};
    params = [contributorEmailPara, typeNamePara, dateFromPara, dateToPara];
    datatable dt;

    try {
        dt = sql:ClientConnector.select(dbConnector,
                                        getAllReviewsQuery + byContributorReviewTypeAndDateQuery, params);


        logger:info("Fetched the review from database successfully");
        //calling the function createResponse(datatable dt)(message m) -> create a formatted JSON response.
        response = createResponseFilteredByContributor(dt, dbConnector);

    } catch (errors:Error err) {
        logger:error(err.msg);
        //set the error message as the response.
        json jsonResponse = {error: {"status": true, "msg": "request failed", reviews: []}};
        messages:setJsonPayload(response, jsonResponse);
    }finally {
        datatables:close(dt);
    }
    return response;
}


@doc:Description {value:"convert the datatable to a JSON object"}
@doc:Param {value:"dt: datatable instance"}
@doc:Return {value:"msg: JSON object as the response message"}
function createResponse(datatable dt)(message msg){
    message response = {};
    json jsonResponse = {error: {"status": false, "msg": ""}, reviews: []};
    json review;
    int previousReviewId = -1;

    logger:debug("Start creating the reviews json reponse");

    try{
        while (datatables:hasNext(dt)) {
            any dataStruct = datatables:next(dt);
            var rowData, _ = (Review)dataStruct;

            if (rowData.review_id != previousReviewId) {

                if (previousReviewId != -1) {
                    // add the created review json object to the "jsonResponse" json
                    jsons:addToArray(jsonResponse, "$.reviews", review);
                }

                //create the json object to represent a review.
                review = {
                             reviewId:rowData.review_id,
                             teamName:rowData.team_name,
                             product:{
                                         productName:rowData.product_name,
                                         productVersion:rowData.product_version
                                     },
                             component: {
                                            componentName:rowData.component_name,
                                            componentVersion:rowData.component_version
                                        },
                             reporter:rowData.reporter,
                             reviewNote:rowData.review_note,
                             references:rowData.reference,
                             reviewDate:rowData.review_date,
                             reviewType:rowData.review_type,
                             participants:rowData.participants,
                             contributor:[rowData.contributor]

                         };

                previousReviewId = rowData.review_id ;

            }else {
                jsons:addToArray(review, "$.contributor", rowData.contributor);
            }
        }
        if (previousReviewId != -1) {
            // add the last created review json object to the "jsonResponse" json
            jsons:addToArray(jsonResponse, "$.reviews", review);
        }


    }catch (errors:NullReferenceError err) {
        logger:error("failed to create the review json object");
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "Internal server error";
        messages:setJsonPayload(response, jsonResponse);
        return response;

    }
    logger:info("successfully created the reviews json response.");
    messages:setJsonPayload(response, jsonResponse);
    return response;

}







@doc:Description {value:"convert the datatable to a JSON object"}
@doc:Param {value:"dt: datatable instance"}
@doc:Param {value:"dbConnector: sql:ClientConnector instance"}
@doc:Return {value:"msg: JSON object as the response message"}
function createResponseFilteredByContributor(datatable dt, sql:ClientConnector dbConnector)(message msg){
    message response = {};
    json jsonResponse = {error: {"status": false, "msg": ""}, reviews: []};
    json review;

    logger:debug("start creating the reviews json reponse");

    try{
        while (datatables:hasNext(dt)) {
            any dataStruct = datatables:next(dt);
            var rowData, _ = (Review)dataStruct;

            //create the json object to represent a review.
            review = {
                         reviewId:rowData.review_id,
                         teamName:rowData.team_name,
                         product:{
                                     productName:rowData.product_name,
                                     productVersion:rowData.product_version
                                 },
                         component: {
                                        componentName:rowData.component_name,
                                        componentVersion:rowData.component_version
                                    },
                         reporter:rowData.reporter,
                         reviewNote:rowData.review_note,
                         references:rowData.reference,
                         reviewDate:rowData.review_date,
                         reviewType:rowData.review_type,
                         participants:rowData.participants,
                         contributor:[]

                     };

            sql:Parameter[] params = [];
            sql:Parameter reviewId = {sqlType:"integer", value:rowData.review_id};
            params = [reviewId];

            datatable contributorDatatable = sql:ClientConnector.select(dbConnector, getAllContributorsByReviewId, params);

            while (datatables:hasNext(contributorDatatable)) {
                any x = datatables:next(contributorDatatable);
                var contributorRowData, _ = (Contributor_email)x;
                jsons:addToArray(review, "$.contributor", contributorRowData.contributor);

            }
            // add the last created review json object to the "jsonResponse" json
            jsons:addToArray(jsonResponse, "$.reviews", review);
        }


    }catch (errors:NullReferenceError err) {
        logger:error("failed to create the review json object");
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "Internal server error";
        messages:setJsonPayload(response, jsonResponse);
        return response;

    }
    logger:info("successfully created the reviews json response.");
    messages:setJsonPayload(response, jsonResponse);
    return response;

}





@doc:Description {value:"sending an email to the given parameters"}
@doc:Param {value:"sender: sender of the email"}
@doc:Param {value:"recipient: receiver of the email"}
@doc:Param {value:"subject: subject of the email"}
@doc:Param {value:"body: msg body of the email"}
@doc:Return {value:"msg: whether succeed or failed"}

function sendEmail (string contributors, string sender, string participants, string groupEmails, string subject, string body, json responseBody)(json msg){

    responseBody = {"error": {"status": true, "msg": "Sending email failed."}};

    try {
        json gmailCredentials = readGmailConfigurations(configJsonPath);
        string userId = jsons:getString(gmailCredentials,"$.gmail.userId");
        string accessToken = jsons:getString(gmailCredentials,"$.gmail.accessToken");
        string refreshToken = jsons:getString(gmailCredentials,"$.gmail.refreshToken");
        string clientId = jsons:getString(gmailCredentials,"$.gmail.clientId");
        string clientSecret = jsons:getString(gmailCredentials,"$.gmail.clientSecret");
        string recipientEmail = jsons:getString(gmailCredentials,"$.gmail.recipientEmail");
        string ccList = contributors + "," + sender + "," + participants + "," + groupEmails;

        logger:debug("initializing gmail connector");
        gmail:ClientConnector gmailConnector = create gmail:ClientConnector(userId,accessToken,refreshToken,
                                                                            clientId,clientSecret);
        logger:debug("gmail connector is initialized ");
        logger:debug("sending the email From: "+userId+", To: " +contributors+ "and "+sender+". Subject: "+subject);

        message response = gmail:ClientConnector.sendMail(gmailConnector, recipientEmail, subject, userId, body, ccList,
                                                          "null", "null", "null", "html");

        int statusCodeOfGmailClientCon = http:getStatusCode(response);
        logger:info("gmail response received with the status code " + statusCodeOfGmailClientCon);
        logger:debug("gmail response: " + messages:getStringPayload(response));
        json responsePayload = messages:getJsonPayload(response);

        if (statusCodeOfGmailClientCon == 200) {
            try{
                json gmailLabelIds = jsons:getJson(responsePayload, "$.labelIds");
                int numOfLabels = lengthof gmailLabelIds;
                boolean isSent = false;
                while (numOfLabels > 0){
                    int index = numOfLabels - 1;
                    string s = jsons:getString(gmailLabelIds,"$.["+index+"]");
                    if(jsons:getString(gmailLabelIds,"$.["+index+"]")  == "SENT"){
                        logger:info("Email is sent successfully");
                        responseBody.error.status = false;
                        responseBody.error.msg = "success";
                        isSent = true;
                        break;
                    }
                    numOfLabels = numOfLabels - 1;
                }
                if(isSent == false){
                    logger:error("Sending email failed.");
                    responseBody.error.status = true;
                    responseBody.error.msg = responsePayload;
                }
            }catch(errors:Error error){
                logger:error("Sending email failed.Error message: " + error.msg);
                logger:debug("gmail response: " + messages:getStringPayload(response));
                responseBody.error.status = true;
                responseBody.error.msg = responsePayload;
            }
        } else {
            logger:error("Sending email failed with status code "+ statusCodeOfGmailClientCon +"...");
            responseBody.error.status = true;
            responseBody.error.msg = responsePayload;
        }
    } catch (errors:Error err) {
        logger:error(err.msg);
        responseBody.error.status = true;
        responseBody.error.msg = "failed to send the email";
    }

    return responseBody;

}

function createEmailBody(string reporterEmail, string contributors, string participants, string groupEmails, string reviewType, string reviewDate,
                         string reviewNotes, string references, string teamName, string componentName,
                         string componentVersion, string productName, string productVersion)(string body){

    body = "<html><head><style>div.detail{padding-left: 30px}</style></head>"+
           "<body>" +
           "<h4>Reporter: </h4><div class='detail'><p>" + reporterEmail + "</p></div>"+
           "<h4>Contributors: </h4><div class='detail'><p>" + contributors +"</p></div>"+
           "<h4>Participants: </h4><div class='detail'><p>" + participants +"</p></div>"+
           "<h4>Group Emails: </h4><div class='detail'><p>" + groupEmails +"</p></div>"+
           "<h4>Review Type: </h4><div class='detail'><p>" + reviewType +"</p></div>"+
           "<h4>Review Date: </h4><div class='detail'><p>" + reviewDate +"</p></div>"+
           "<h4>Team: </h4><div class='detail'><p>" + teamName +"</p></div>"+
           "<h4>Product: </h4><div class='detail'><p>" + productName + " - " + productVersion +"</p></div>"+
           "<h4>Component: </h4><div class='detail'><p>" + componentName + " - " + componentVersion +"</p></div>"+
           "<h4>Review Notes: </h4><div class='detail'><p>" + reviewNotes +"</p></div>"+
           "<h4>References: </h4><div class='detail'><p>" + references +"</p></div>"+
           "</body></html>"
    ;

    logger:info("email body: " + body);

    return body;
}


function readGmailConfigurations(string configJsonPath)(json credentials){
    //
    files:File configFile;
    json configJson = {};
    try{
        logger:debug("set the file path and open file for reading");
        configFile = {path: configJsonPath};
        files:open(configFile, "r");

        // read the contents of the file and close the file
        var content, numberOfBytes = files:read(configFile, 100000);
        // read the contents as string and then convert it to json
        string configString = blobs:toString(content, "utf-8");
        configJson = jsons:parse(configString);

    }catch(errors:Error er){

    }finally{
        files:close(configFile);
    }
    return configJson;


}
