import ballerina/data.xmldata;
import ballerina/ftp;
import ballerina/io;
import ballerinax/rabbitmq;
import ballerinax/wso2.controlplane as _;

final rabbitmq:Client orderClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT, username = "admin", password = "admin");

listener ftp:Listener fileListener = new ({
    host: "localhost",
    auth: {
        credentials: {
            username: "user1",
            password: "pass456"
        }
    },
    pollingInterval: 10,
    fileNamePattern: "(.*).csv"
});

service on fileListener {

    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {

        foreach ftp:FileInfo addedFile in event.addedFiles {
            io:println("New file is added: " + addedFile.pathDecoded);

            check streamRemoteFileToLocal(addedFile, caller);
            check publishToEachQueue(addedFile);

            _ = check caller->delete(addedFile.pathDecoded);
        }
    }
}

function streamRemoteFileToLocal(ftp:FileInfo addedFile, ftp:Caller caller) returns error? {
    stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
    check io:fileWriteBlocksFromStream(string `../local/${addedFile.name}`, fileStream);
    check fileStream.close();
}

function publishToEachQueue(ftp:FileInfo addedFile) returns error? {
    check declareQueue();

    stream<Person, io:Error?> csvStream = check io:fileReadCsvAsStream(string `../local/${addedFile.name}`);
    _ = check from Person person in csvStream
        do {
            Student student = check mapPersonToStudent(person);
            xml studentXml = check xmldata:toXml(student);
            check orderClient->publishMessage({
                content: studentXml,
                routingKey: "PersonQueue"
            });
        };
}

function declareQueue() returns error? {
    _ = check orderClient->queueDeclare("PersonQueue");
    _ = check orderClient->exchangeDeclare("PersonExchange", "direct");
    _ = check orderClient->queueBind("PersonQueue", "PersonExchange", "PersonQueue");
}

function mapPersonToStudent(Person person) returns Student|error => {
    id: person.id,
    name: person.name,
    salary: check float:fromString(person.salary),
    subjects: re `,`.split(person.subjects)
};

type Person record {
    string id;
    string name;
    string salary;
    string email;
    string phone;
    string subjects;
    string vehicles;
};

type Student record {
    string id;
    string name;
    float salary;
    string[] subjects;
};
