---
description: How to start the .NET backend API server for development, with correct file paths for the current project.
---

# Run Backend Workflow

## 1. Start the API
```powershell
cd d:\FlutterProjects\gitlove\Kemora\Kemora.Api
dotnet run
```
The API will start on:
- HTTP: `http://0.0.0.0:5299` (reachable from emulator using `10.0.2.2:5299`)
- HTTPS: `https://localhost:7210`

## 2. Free dev port if needed (5299)
```powershell
$portPid = (netstat -ano | Select-String ":5299" | ForEach-Object { ($_ -split "\s+")[-1] } | Where-Object { $_ -match "^\d+$" } | Select-Object -First 1)
if ($portPid) { Stop-Process -Id ([int]$portPid) -Force -ErrorAction SilentlyContinue }
```

## 3. Open Swagger UI (dev only)
Navigate to `http://localhost:5299/swagger` to test API endpoints.

## 4. Health Check
Navigate to `http://localhost:5299/health` to verify the server and database are connected.

## 5. Common startup issues
- `address already in use`: another API process already occupies port 5299. Stop it, then rerun.
- SQL connection error: ensure `ConnectionStrings:DefaultConnection` targets your SQL instance (for this repo, `Server=.\\SQLEXPRESS;...`).
- Missing `.env` file: copy `.env.example` to `.env` and fill in required values.
