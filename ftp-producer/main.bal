import ballerina/ftp;
import ballerina/io;

configurable string host = "localhost";
configurable int port = 21;
configurable string username = "user1";
configurable string password = "pass456";
configurable string fileName = "/people.csv";

public function main() returns error? {
    ftp:Client fileClient = check new ({
        host,
        port,
        auth: {
            credentials: {
                username,
                password
            }
        }
    });

    stream<io:Block, io:Error?> fileStream = check io:fileReadBlocksAsStream("../files/people.csv", 1024);
    check fileClient->put(fileName, fileStream);
    check fileStream.close();
}