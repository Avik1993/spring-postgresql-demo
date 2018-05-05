[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Spring Boot 2.0 PostgreSQL Application Demonstration

This project was originally used for the Programmatic Ponderings blog post, [Developing Cloud-Native Data-Centric Spring Boot Applications for Pivotal Cloud Foundry](https://wp.me/p1RD28-5Jh), published March, 2018. Spring Boot 2.0 application, backed by PostgreSQL, and designed for deployment to Pivotal Cloud Foundry (PCF). Database changes are handled by Liquibase.

Also, this project was used for the two-part Programmatic Ponderings post, [Managing Applications Across Multiple Kubernetes Environments with Istio](https://wp.me/p1RD28-5L7), published April, 2018.

## Docker Quick Start

The project now contains `Dockerfile` and `docker-compose.yml` files. If you have Docker and Docker Compose installed locally, you can preview project by creating Docker containers for both the PostgreSQL database and the Spring Boot application. To do so, execute the follow command from the root of the project

```bash
git clone --depth 1 --branch master \
  https://github.com/garystafford/spring-postgresql-demo.git
cd spring-postgresql-demo

docker-compose -p springdemo up -d
```

To follow the startup of the Spring Boot application, use the `docker logs springdemo --follow` command. When complete, browse to `http://localhost:8080`. See the list of available resources below.

To delete both Docker containers when done previewing, use the `docker rm -f postgres springdemo` command.

## Build and Run Application with Gradle

The project assumes you have Docker and the Cloud Foundry Command Line Interface (cf CLI) installed locally.

First, provision the local PostgreSQL development database using Docker:

```bash
# create container
docker run --name postgres \
  -e POSTGRES_USERNAME=postgres \
  -e POSTGRES_PASSWORD=postgres1234 \
  -e POSTGRES_DB=elections \
  -p 5432:5432 \
  -d postgres

# view container
docker container ls

# trail container logs
docker logs postgres  --follow
```

Local database connection details are set in the `src\main\resources\application.yml` file.

The `default` Spring Profile, uses an [h2](http://www.h2database.com/) instance:

```yaml
datasource:
  url: jdbc:h2:mem:elections
  username: sa
  password:
  driver-class-name: org.h2.Driver
  jpa:
    show-sql: true
h2:
  console:
    enabled: true
```

The `dev` Spring Profile, uses localhost PostgreSQL instance:

```yaml
datasource:
  url: jdbc:postgresql://localhost:5432/elections
  username: postgres
  password: postgres1234
  driver-class-name: org.postgresql.Driver
jpa:
  show-sql: true
```

Optionally, you can override any of the setting in the `src\main\resources\application.yml` files, by setting local environment variables, such as:

```bash
# use 'set' on Windows
export SPRING_PROFILES_ACTIVE=<profile>
export SPRING_DATASOURCE_URL=<some_other_url>
export SPRING_DATASOURCE_USERNAME=<some_other_username>
export SPRING_DATASOURCE_PASSWORD=<some_other_password>
```

Next, build and run service locally, using Gradle, against the local Docker PostgreSQL database instance. This command will also execute the Liquibase change sets on the Docker PostgreSQL `elections` database.

```bash
SPRING_PROFILES_ACTIVE=dev ./gradlew clean bootRun
```

To view Liquibase database changelog:

```postgresplsql
SELECT * FROM databasechangelog;
```

To delete the local Docker-based PostgreSQL database:

```bash
docker rm -f postgres
```

## Deploy to Pivotal Web Services

Purchase and provision an ElephantSQL PostgreSQL as a Service instance through the Pivotal Services Marketplace. Note the 'panda' service plan is NOT FREE! To purchase, you must have a Pivotal account with a credit card attached.

```bash
# view elephantsql service plans
cf marketplace -s elephantsql

# purchase elephantsql service plan
cf create-service elephantsql panda elections

# display details of running service
cf service elections
```

Deploy the Spring Boot service to Pivotal Web Services.

```bash
gradle build && cf push
```

Scale up instances:

```bash
# scale up to 2 instances
cf scale cf-spring -i 2

# review status of both instances
cf app pcf-postgresql-demo
```

## Available Resources

Below is a partial list of the application's exposed resources. To see all resources, use the `/actuator/mappings` resource.

-   h2 (`default` Spring Profile only)

    -   `/h2-console`

-   Actuator

    -   `/`
    -   `/actuator/mappings` (shows all resources!)
    -   `/actuator/metrics`
    -   `/actuator/metrics/{metric}`
    -   `/actuator/liquibase`
    -   `/actuator/env`
    -   `/actuator/configprops`
    -   `/actuator/health`
    -   `/actuator/info`
    -   `/actuator/beans`

-   Swagger

    -   `/swagger-ui.html`
    -   `/v2/api-docs`

-   Candidates (DB Table)

    -   `/candidates`
    -   `/candidates/{id}`
    -   `/profile/candidates`
    -   `/candidates/search`
    -   `/candidates/search/findByLastName?lastName=Obama`
    -   `/candidates/search/findByPoliticalParty?politicalParty=Democratic%20Party`
    -   `/candidates/summary` (GET - via `CandidateController`)
    -   `/candidates/summary/{politicalParty}` (GET - via `CandidateController`)

-   Elections (DB Table)

    -   `/elections`
    -   `/elections/{id}`
    -   `/profile/elections`
    -   `/elections/search`
    -   `/elections/search/findByTitle?title=2012%20Presidential%20Election`
    -   `/elections/search/findByDescriptionContains?description=American`
    -   `/elections/summary` (GET - via `ElectionController`)


-   Votes (DB Table)

    -   `/votes`
    -   `/votes/{is}`
    -   `/votes?page={page}}&size={size}`
    -   `/profile/votes`

-   Election Candidates (DB Table)

    -   `/electionCandidates`
    -   `/profile/electionCandidates`

-   Candidates, by Elections (DB View)

    -   `/election-candidates` (GET only)
    -   `/profile/election-candidates`
    -   `/election-candidates/search/findByElection?election=2016%20Presidential%20Election`

-   Individual Votes, by Election (DB View)

    -   `/election-votes` (GET only)
    -   `/election-votes?page={page}}&size={size}` (GET only)
    -   `/profile/election-votes`
    -   `/election-votes/search/findByElection?election=2012%20Presidential%20Election`
    -   `/election-votes/summary` (GET - via `ElectionsCandidatesViewController`)
    -   `/election-votes/summary/{election}` (GET - via `ElectionsCandidatesViewController`)

-   Total Votes by Election and by Candidate (DB View)

    -   `/vote-totals` (GET only)
    -   `/profile/vote-totals`
    -   `/vote-totals/search/findByElection?election=2012%20Presidential%20Election`
    -   `/election-votes/summary` (GET - via `VoteTotalsViewController`)

## References

-   <https://auth0.com/blog/integrating-spring-data-jpa-postgresql-liquibase>
-   <http://mrbool.com/rest-server-with-spring-data-spring-boot-and-postgresql/34023>
-   <https://www.tutorialspoint.com/postgresql/postgresql_create_database.htm>
-   <http://www.vogella.com/tutorials/Lombok/article.html>
-   <https://spring.io/guides/gs/accessing-data-jpa>
-   <https://dzone.com/articles/integrating-spring-data-jpa-postgresql-and-liquiba>
-   <https://www.javabullets.com/calling-database-views-from-spring-data-jpa>
-   <http://www.baeldung.com/swagger-2-documentation-for-spring-rest-api>
