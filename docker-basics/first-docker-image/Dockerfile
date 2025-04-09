#  A Dockerfile must begin with a FROM instruction that specifies the base-image of our image 
FROM ubuntu:latest

# it creates and sets the working directory for following instructions 
WORKDIR /app

# this is to copy the source file inside /app (The destination dir must have a trailing slash ). Also creates a new layer.
COPY . /app/

# it sets the command to be executed when running a container from an image
ENTRYPOINT ["./simple-bash"]

#   ENTRYPOINT vs CMD
# ---------------------
# Both CMD and ENTRYPOINT instructions define what command gets executed when running a container.
# But, ENTRYPOINT instructions can not be overridden unlike CMD instructions.
# hence, we can use  ENTRYPOINT to set fairly stable default commands and arguments 
# and then use CMD to set additional defaults that are more likely to be changed.

# we can override the ENTRYPOINT instruction using the "--entrypoint" flag with `docker run`.

# Significance of Trailing Slashes
# ---------------------------------
# 1. Without a trailing slash: COPY test.txt /abs This creates a file named abs in the root directory of the container. The content of this file will be the same as test.txt.
# 2. With a trailing slash: COPY test.txt /abs/ This creates a file named test.txt inside the /abs directory. If the /abs directory doesn't exist, Docker will create it.