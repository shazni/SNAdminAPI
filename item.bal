import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

public type Item record {
    string name;
    string description;
    string includeDetail;
    string includedFor;
    string color;
    string material;
    decimal price;
};

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3}
);

isolated function getAllItems() returns Item[]|error {
    stream<Item, error?> resultStream = dbClient->query(`    
        SELECT id, name, description, includeDetail, includedFor, color, material, price from SNStoreItem;
    `);

    Item[] products = [];
    check from Item product in resultStream
        do {
            products.push(product);
        };
    check resultStream.close();
    return products;
}

isolated function addItem(Item item) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`   
        INSERT INTO snstoreitem (name, description, includeDetail, includedFor, color, material, price)
        VALUES (${item.name}, ${item.description}, ${item.includeDetail}, ${item.includedFor}, ${item.color}, ${item.material}, ${item.price}); 
    `);

    int|string? lastInsertId = result.lastInsertId;
    if lastInsertId is int {
        return lastInsertId;
    } else {
        return error("Failed to retrieve last inserted ID");
    }
}

isolated function updateItem(int id, Item item) returns int|error {
    sql:ExecutionResult|error result = dbClient->execute(`    
        UPDATE snstoreitem SET
            name = ${item.name},
            description = ${item.description},
            includeDetail = ${item.includeDetail}, 
            includedFor = ${item.includedFor},
            color = ${item.color},
            material = ${item.material},
            price = ${item.price}
        WHERE id = ${id}
    `);

    if result is error {
        io:println("There was an error updating");
        return 0;
    }

    int|string? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Failed to retrieve affected row count");
    }
}

isolated function deleteItem(int itemId) returns int|error {
    sql:ExecutionResult result = check dbClient->execute(`    
        DELETE FROM snstoreitem WHERE id = ${itemId};
    `);

    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount is int {
        return affectedRowCount;
    } else {
        return error("Failed to retrieve the affected row count");
    }
}

isolated function getItemById(int id) returns Item?|error {
    Item? item = check dbClient->queryRow(`       
        SELECT id, name, description, includeDetail, includedFor, color, material, price from SNStoreItem WHERE id = ${id} ;
    `);

    return item;
}