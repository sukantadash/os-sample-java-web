# Stage 1: Build the WAR file
FROM registry.access.redhat.com/ubi8/openjdk-11 AS builder

WORKDIR /build

# Install Maven
RUN dnf install -y maven && dnf clean all

# Clone the application repository
RUN git clone https://github.com/openshiftdemos/os-sample-java-web.git /build

# Build the application
RUN mvn package -DskipTests

# Stage 2: Deploy the WAR file to JBoss Web Server 5.7
FROM registry.redhat.io/jboss-webserver-5/jboss-webserver57-openjdk11-tomcat9-openshift-ubi8

WORKDIR /opt/jws-5.7/

# Copy the built WAR file into Tomcat's webapps directory
COPY --from=builder /build/target/*.war ./webapps/app.war

# Expose Tomcat's port
EXPOSE 8080

# Run JWS (Tomcat)
CMD ["bin/catalina.sh", "run"]
