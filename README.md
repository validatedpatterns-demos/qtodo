# Persistent Todo Application (qtodo)

This sample persistent todo application uses Quarkus.

If you want to learn more about Quarkus, please visit its website: <https://quarkus.io/>.

This application uses Red Hat's Maven repositories to download its dependencies and thus establish a trusted source.

## Running the application in dev mode


### Prerequisites

To build locally:
    - Java 17+

To build and run the application in containers:
    - Docker or Podman

* A PostgreSQL database instance (ensure it's accessible and update application.properties with its connection details).

### Running postgres db locally in a container
> **_NOTE:_**  Application expects to have a postgres db running on localhost on port 5432 when running locally
This requires registering with registry.redhat.io to be able to pull the appropriate UBI backed container image

**Usage:**
```bash

# Run Red Hat UBI based container image with Postgres
podman run -d --name postgresql_database -e POSTGRESQL_USER=qtodo_user -e POSTGRESQL_PASSWORD=RedH@tPassw0rd -e POSTGRESQL_DATABASE=tasks -p 5432:5432 registry.redhat.io/rhel8/postgresql-16
```

You can then run your application in dev mode that enables live coding using:

```shell script
./mvnw -s settings.xml quarkus:dev
```

### Running using containers

If you have [built the container beforehand](#creating-a-container-with-the-application), you can start a pod with the application and the database using podman:

```shell
podman play kube resources/qtodo-pod.yaml
```

### Accessing the web application:
Open your web browser and navigate to http://localhost:8080/.

Tasks will be persisted in the PostgreSQL database.
![Alt text](./resources/images/qtodo.png)

## Packaging and running the application

The application can be packaged using:

```shell script
./mvnw package
```

It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:

```shell script
./mvnw package -Dquarkus.package.jar.type=uber-jar
```
- or -
```shell script
make build
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using:

```shell script
./mvnw -s settings.xml package -Dnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using:

```shell script
./mvnw -s settings.xml package -Dnative -Dquarkus.native.container-build=true
```

## Creating a container with the application

If you want to create a container with the qtodo application, you can do so using:

```shell script
make build-image
```

We can also add our own manually generated _jar_ to the image instead of performing the build step. That file must be in the `target/` directory.
```shell script
export ARTIFACT=qtodo-example-runner.jar

make build-image-binary
```
