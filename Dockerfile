# Use an official Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


# Install dependencies
RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
                       libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
                       libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
                       python3-openssl git

# Download and build Python 3.10.12
RUN wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz && \
    tar xzf Python-3.10.12.tgz && \
    cd Python-3.10.12 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall

# Clean up unnecessary files
RUN rm -rf Python-3.10.12* && \
    apt-get autoremove -y && \
    apt-get clean

# Install system dependencies
RUN apt-get update \
    && apt-get install -y pkg-config libxml2-dev libxmlsec1-dev libxmlsec1-openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


## Set the working directory in the container
WORKDIR /app

## Copy the requirements file into the container
COPY requirements.txt /app/

## Install Python dependencies
RUN python3.10 -m pip install -U virtualenv \
    && python3.10 -m pip install --upgrade pip \
    && python3.10 -m pip install -r requirements.txt

## Copy the current directory contents into the container at /app
COPY . /app/

## Start the Django development server
CMD ["python3.10", "manage.py", "runserver", "0.0.0.0:8000"]
