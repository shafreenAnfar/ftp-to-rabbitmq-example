
# Ballerina Integration Pipeline: FTP to RabbitMQ

This repository contains two Ballerina programs: **Consumer** and **Producer**. Both programs automate data processing by monitoring FTP servers, transforming data, and interacting with RabbitMQ for message queuing.


## Features

- **FTP Integration**: Monitors an FTP directory for new `.csv` files.
- **File Downloading**: Streams files from remote FTP servers to a local directory.
- **Data Transformation**: Reads CSV records, converts them into XML, and maps fields into structured formats.
- **RabbitMQ Messaging**: Publishes transformed data to RabbitMQ queues for further processing.
- **Automation**: Automatically deletes files after successful processing.

## Setup environment

```bash
docker compose up
```

## How It Works

### 1. Consumer Program

The **Consumer Program** performs the following steps:

1. Monitors the FTP server for new `.csv` files.
2. Downloads files locally to a predefined directory.
3. Processes the files by:
   - Parsing CSV content into a `Person` record type.
   - Mapping `Person` to `Student` and converting to XML.
4. Publishes the XML message to the RabbitMQ queue `PersonQueue`.

### 2. Producer Program

The **Producer Program** produces messages to FTP server.

## Usage

### 1. Run the Consumer Program
Start the consumer program to monitor and process `.csv` files:
```bash
bal run consumer.bal
```

### 2. Run the Producer Program
Launch the producer program if separate data injection is required:
```bash
bal run producer.bal
```

### 3. Observe the Output
- Logs indicating new files detected and processed.
- Messages published to RabbitMQ.

## Data Types

### Person Record
Represents raw CSV data:
```ballerina
type Person record {
    string id;
    string name;
    string salary;
    string email;
    string phone;
    string subjects;
    string vehicles;
};
```

### Student Record
Transformed and enriched data:
```ballerina
type Student record {
    string id;
    string name;
    float salary;
    string[] subjects;
};
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
