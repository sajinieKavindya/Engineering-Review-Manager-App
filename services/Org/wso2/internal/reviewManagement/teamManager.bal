package Org.wso2.internal.reviewManagement;


import ballerina.lang.messages;
import ballerina.data.sql;
import ballerina.lang.datatables;
import ballerina.lang.jsons;
import ballerina.lang.errors;
import ballerina.utils.logger;
import ballerina.doc;
import ballerina.lang.strings;

@doc:Description {value:"Team definition"}
@doc:Field {value:"team_name: name of the team"}
@doc:Field {value:"team_email: email of the team"}
struct Team {
    int pqd_area_id;
    string pqd_area_name;
}


function getAllTeams(sql:ClientConnector dbConnector)(message ){

    message response = {};
    datatable dt;
    json jsonResponse = {error: {"status": false, "msg": ""}, teams: []};

    try {
        sql:Parameter[] params = [];
        logger:debug("start fetching all the teams from the database");
        dt = sql:ClientConnector.select(dbConnector, getAllTeamsQueryNew, params);
        logger:info("Fetched all the teams from database successfully");

        json team;

        //Iterate through the result until hasNext() become false and retrieve the data struct corresponding to each row.
        //create the team json object
        logger:debug("Start creating the teams json reponse");

        while (datatables:hasNext(dt)) {
            any dataStruct = datatables:next(dt);
            var rowData, _ = (Team)dataStruct;
            string id = strings:valueOf(rowData.pqd_area_id);
            team = {
                       teamId:id,
                       teamName:rowData.pqd_area_name
                   };

            // add the created team json object to the "jsonResponse" json
            if(rowData.pqd_area_name != "No Product"){
                jsons:addToArray(jsonResponse, "$.teams", team);
            }

        }
        logger:info("successfully created the teams json response.");

    } catch (errors:NullReferenceError err) {
        logger:error("failed to create the team json object");
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "Internal server error";

    } catch (errors:Error err) {
        logger:error(err.msg);
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "request failed";

    }finally {
        datatables:close(dt);
        messages:setJsonPayload(response, jsonResponse);
    }
    return response;
}
