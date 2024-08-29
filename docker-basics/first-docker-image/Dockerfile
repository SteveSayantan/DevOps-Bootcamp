#  A Dockerfile must begin with a FROM instruction that specifies the base-image of our image 
FROM ubuntu:latest

# it creates and sets the working directory for following instructions 
WORKDIR /app

# this is to copy the source file inside /app (The destination dir must have a trailing slash )
COPY . /app/

# it sets the command to be executed when running a container from an image
CMD ./simple-bash


