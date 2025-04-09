# Use the official OpenJDK 17 image as the base image
FROM openjdk:17-jdk-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY src/*.java .

COPY quotes.txt quotes.txt

# Compile the Java code
RUN javac *.java   

# we'll get Main.class

RUN jar -c -f main.jar -e Main Main.class

# we'll get main.jar

FROM gcr.io/distroless/java17-debian12

COPY --from=builder /app/main.jar /app/quotes.txt /app/

WORKDIR /app

# Expose port 8000 for the HTTP server
EXPOSE 8000

# Run the Java application when the container starts
CMD ["main.jar" ]