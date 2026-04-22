#testing my python app in docker
FROM python:3.8-slim

WORKDIR  /app

COPY vote ./

RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "sh", "-c", "python app.py" ]