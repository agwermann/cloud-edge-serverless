# Cloud Service

## Setup Virtual environment

```bash
python3 -m venv venv
```

## Build Docker Container

```bash
docker build -t dev.local/cloud-event-handler:0.1 .
docker compose up -d
```
