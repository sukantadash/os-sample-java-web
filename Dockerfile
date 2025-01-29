# Stage 1: Build the WAR file
FROM registry.access.redhat.com/ubi8/openjdk-17 AS builder

WORKDIR /build

# Optimize Maven build caching
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Create final runtime container with JWS (Tomcat)
FROM registry.redhat.io/jboss-webserver-5/webserver55-tomcat9-rhel8

WORKDIR /opt/jboss/webserver/

# Security: Add a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser

# Copy built WAR file into Tomcat’s webapps directory
COPY --from=builder /build/target/*.war ./webapps/app.war

# Expose the Tomcat port
EXPOSE 8080

# Run JWS (Tomcat) with optimized settings
CMD ["bin/catalina.sh", "run"]
