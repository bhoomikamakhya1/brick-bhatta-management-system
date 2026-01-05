# Brick Bhatta Management System Backend

FastAPI backend with PostgreSQL for the Brick Bhatta Management System.

## Setup

### Prerequisites
- Docker & Docker Compose
- Python 3.10+ (for local dev without Docker)

### Running with Docker (Recommended)

1.  **Start the services**:
    ```bash
    docker compose up -d --build
    ```

2.  **Access the API**:
    - API Root: `http://localhost:8000`
    - Swagger Documentation: `http://localhost:8000/docs`
    - Health Check: `http://localhost:8000/health`

### Local Development (No Docker)

1.  **Create venv**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # Windows: venv\Scripts\activate
    ```

2.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

3.  **Run DB**: Use a local Postgres instance or Docker for just DB:
    ```bash
    docker run --name brick-db -e POSTGRES_PASSWORD=password -e POSTGRES_DB=brick_bhatta_db -p 5432:5432 -d postgres:15
    ```

4.  **Run App**:
    ```bash
    uvicorn app.main:app --reload
    ```

## API Structure

- `/users`: User management (Auth required)
- `/sales`: Sales transactions (Auth required)
- `/names`: Legacy name list

## Authentication

Authentication is handled via Firebase ID Tokens. Send the token in the `Authorization` header:

```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

**Note**: You must place your `firebase_credentials.json` in `backend/app/` or set `FIREBASE_CREDENTIALS_PATH` environment variable for robust server-side verification.
