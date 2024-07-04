##stage 1
# Use a base image that includes Java 8
FROM openjdk:8-jdk-alpine as build
# Set environment variables for Maven
ENV MAVEN_VERSION 3.6.3
ENV MAVEN_HOME /usr/share/maven
# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O /tmp/apache-maven.tar.gz && \
    tar xzf /tmp/apache-maven.tar.gz -C /usr/share && \
    mv /usr/share/apache-maven-$MAVEN_VERSION $MAVEN_HOME && \
    ln -s $MAVEN_HOME/bin/mvn /usr/bin/mvn
# Set the working directory in the container
WORKDIR /app
# Copy the Spring MVC application source code to the container
COPY . .
RUN rm -rf target
# Build the application using Maven
RUN mvn clean install

##stage 2
# Use a Tomcat image as the final image
FROM tomcat:9-jre8
# Copy the built Spring MVC WAR file to Tomcat's webapps directory
COPY --from=build /app/target/SpringSessionRedis.war /usr/local/tomcat/webapps/SpringSessionRedis.war
#COPY --from=build /app/target/SpringSessionRedis-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/app.war
# Expose the default Tomcat port (adjust as needed)
EXPOSE 8080
# Start Tomcat when the container starts
CMD ["catalina.sh", "run"]
