import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service /snitemrest on new http:Listener(9090) {

    resource function get item/[int id]() returns Item?|error {
        return getItemById(id);
    }

    resource function get items() returns Item[]|error {
        return getAllItems();
    }

    @http:ResourceConfig {
    consumes: ["application/json"]
    }
    resource function post item(@http:Payload Item itemDetail)
            returns http:Created|http:BadRequest {

        int|error lastInsertedId = addItem(itemDetail);

        if lastInsertedId is error {
            http:BadRequest badRequest = {};
            return badRequest;
        }

        http:Created created = {
            body : { 
                "last_inserted_id" : lastInsertedId
            }
        };

        return created;
    }

    resource function put item/[int id](@http:Payload Item item) returns int|error {
        return updateItem(id, item);
    }

    resource function delete item/[int id]() returns int|error {
        return deleteItem(id);
    }
}
