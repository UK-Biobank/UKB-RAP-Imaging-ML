FROM python:3.9-slim
FROM openjdk:8

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y python3-venv python3-distutils python3-pip && apt-get clean

# Open a port for the container
EXPOSE 8000

RUN python3 -m pip install stepcount