FROM python:3.10-slim

WORKDIR /app

# Copy the contents of the app folder
COPY app/ .

RUN pip install Flask

EXPOSE 8080

CMD ["python", "main.py"]
