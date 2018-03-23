# Spring Boot 2.0 PostgreSQL Application Demonstration

Project for the Programmatic Ponderings blog post, [Developing Cloud-Native Data-Centric Spring Boot Applications for Pivotal Cloud Foundry](https://wp.me/p1RD28-5Jh), published March 23, 2018. Spring Boot 2.0 application, backed by PostgreSQL, and designed for deployment to Pivotal Cloud Foundry (PCF). Database changes are handled by Liquibase.

## Build and Run

The project assumes you have Docker and the Cloud Foundry Command Line Interface (cf CLI) installed locally.

Provision the local PostgreSQL development database using Docker:

```bash
docker run --name postgres \
  -e POSTGRES_USERNAME=postgres \
  -e POSTGRES_PASSWORD=postgres1234 \
  -e POSTGRES_DB=elections \
  -p 5432:5432 \
  -d postgres
```

Local database connection details are set in the `src\main\resources\application.yml` file.

```yaml
datasource:
  url: jdbc:postgresql://localhost:5432/elections
  username: postgres
  password: postgres1234
  driver-class-name: org.postgresql.Driver
jpa:
  show-sql: true
```

Optionally, you can override any of the setting in the `src\main\resources\application.yml` files, `default` Spring Profile by setting local environment variables, such as:

```bash
# 'export' on linux and mac
set SPRING_DATASOURCE_URL=some_other_url
set SPRING_DATASOURCE_USERNAME=some_other_username
set SPRING_DATASOURCE_PASSWORD=some_other_password
```

Build and run service locally using local Docker PostgreSQL database instance. This command will also execute the Liquibase change sets on the Docker PostgreSQL `elections` database.

```bash
gradle bootRun
```

To view Liquibase database changelog:

```postgresplsql
SELECT * FROM databasechangelog;
```

## Deploy to Pivotal Web Services

Purchase and provision an ElephantSQL PostgreSQL as a Service instance through the Pivotal Services Marketplace. Note the 'panda' service plan is NOT FREE! To purchase, you must have a Pivotal account with a credit card attached.

```bash
cf marketplace -s elephantsql
cf create-service elephantsql panda elections
```

Deploy the Spring Boot service to Pivotal Web Services.

```bash
gradle build && cf push
```

Scale up instances:

```bash
cf scale cf-spring -i 2
cf app pcf-postgresql-demo
```

## Available Resources
Here is just a partial list of exposed resources:
- Actuator
  - `/actuator/mappings`
  - `/actuator/metrics`
  - `/actuator/env`
  - `/actuator/configprops`
  - `/actuator/health`
  - `/actuator/info`
- Candidates
  - `/candidates` (GET, POST, PUT, DELETE)
  - `/profile/candidates`
  - `/candidates/search/findByLastName?lastName=Obama`
  - `/candidates/search/findByPoliticalParty?politicalParty=Democratic%20Party`
- Elections
  - `/elections` (GET, POST, PUT, DELETE)
  - `/profile/elections`
  - `/elections/search/findByTitle?title=2012%20Presidential%20Election`
  - `/elections/search/findByDescriptionContains?description=American`
- Candidates by Elections View
  - `/electioncandidates` (GET only)
  - `/profile/electioncandidates`
  - `/electioncandidates/search/findByElection?election=2016%20Presidential%20Election`
- Votes by Elections View
  - `/electionvotes` (GET only)
  - `/profile/electionvotes`
  - `/electionvotes/search/findByElection?election=2012%20Presidential%20Election`

## References

- <https://auth0.com/blog/integrating-spring-data-jpa-postgresql-liquibase>
- <http://mrbool.com/rest-server-with-spring-data-spring-boot-and-postgresql/34023>
- <https://www.tutorialspoint.com/postgresql/postgresql_create_database.htm>
- <http://www.vogella.com/tutorials/Lombok/article.html>
- <https://spring.io/guides/gs/accessing-data-jpa>
- <https://dzone.com/articles/integrating-spring-data-jpa-postgresql-and-liquiba>
- <https://www.javabullets.com/calling-database-views-from-spring-data-jpa>
