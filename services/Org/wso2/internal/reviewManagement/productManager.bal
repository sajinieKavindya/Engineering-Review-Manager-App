package Org.wso2.internal.reviewManagement;

import ballerina.lang.messages;
import ballerina.data.sql;
import ballerina.lang.datatables;
import ballerina.lang.jsons;
import ballerina.lang.errors;
import ballerina.utils.logger;
import ballerina.doc;
import ballerina.lang.strings;

@doc:Description {value:"Product definition"}
@doc:Field {value:"product_id: id of the Product"}
@doc:Field {value:"product_name: name of the Product"}
@doc:Field {value:"product_version: version of the Product"}
struct Product {
    int pqd_product_id;
    string pqd_product_name;
}

function getProductsByTeam(int team, sql:ClientConnector dbConnector)(message msg){

    message response = {};
    datatable dt;
    json jsonResponse = {error: {"status": false, "msg": ""}, products: []};

    try {
        sql:Parameter[] params = [];
        sql:Parameter teamPara = {sqlType:"integer", value:team};
        params = [teamPara];

        logger:debug("start fetching all the products for team "+team+" from the database");
        dt = sql:ClientConnector.select(dbConnector, getAllProductsByTeamQueryNew, params);
        logger:info("Fetched all the products for team "+team+" from database successfully");

        json product;

        //Iterate through the result until hasNext() become false and retrieve the data struct corresponding
        //to each row.
        //create the product json object
        logger:debug("Start creating the products json reponse");
        while (datatables:hasNext(dt)) {
            any dataStruct = datatables:next(dt);
            var rowData, _ = (Product)dataStruct;
            string id = strings:valueOf(rowData.pqd_product_id);

            product = {
                          productId:id,
                          productName:rowData.pqd_product_name
                      };

            // add the created product json object to the "jsonResponse" json
            jsons:addToArray(jsonResponse, "$.products", product);
        }
        logger:info("successfully created the products json response.");

    } catch (errors:NullReferenceError err) {
        logger:error("failed to create the product json object");
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "Internal server error";

    } catch (errors:Error err) {
        logger:error(err.msg);
        jsonResponse.error.status = true;
        jsonResponse.error.msg = "request failed";

    } finally {
        datatables:close(dt);
        messages:setJsonPayload(response, jsonResponse);
    }
    return response;
}




function getProducts(sql:ClientConnector dbConnector)(message msg){
    message response = {};
    datatable dt;
    json jsonResponse = {error: {"status": false, "msg": ""}, products: []};

    try {
        sql:Parameter[] params = [];
        logger:debug("start fetching all the products from the database");
        dt = sql:ClientConnector.select(dbConnector, getAllProductsQueryNew, params);
        logger:info("Fetched all the products from database successfully");

        json product;

        //Iterate through the result until hasNext() become false and retrieve the data struct corresponding to each row.
        //create the team json object
        logger:debug("Start creating the products json reponse");
        while (datatables:hasNext(dt)) {
            any dataStruct = datatables:next(dt);
            var rowData, _ = (Product)dataStruct;
            string id = strings:valueOf(rowData.pqd_product_id);

            product = {
                          productId:id,
                          productName:rowData.pqd_product_name
                      };

            // add the created product json object to the "jsonResponse" json
            jsons:addToArray(jsonResponse, "$.products", product);
        }
        logger:info("successfully created the product json response.");

    } catch (errors:NullReferenceError err) {
        logger:error("failed to create the product json object");
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