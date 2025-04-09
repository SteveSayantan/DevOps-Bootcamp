# Use an official Python runtime as the base image
FROM python:3.9-slim


RUN apt-get update -y \  
&& apt-get upgrade -y \
&& apt-get install -y build-essential default-libmysqlclient-dev pkg-config \
&& rm -rf /var/lib/apt/lists/* 

# Set the working directory in the container
WORKDIR /app
# Copy the requirements file into the container
COPY requirements.txt .

# Install app dependencies

RUN pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

# Specify the command to run your application
CMD ["python", "app.py"]



