#!/usr/bin/env pwsh
# LuckyAI 645 - 모든 프로세스 종료 스크립트
# 
# 2026-01-05 16:50:00 EST - 초기 생성
# 
# 사용법:
#   .\stop_all.ps1

Write-Host "`nStopping LuckyAI 645 processes...`n" -ForegroundColor Yellow

# Stop Uvicorn (FastAPI) processes
Write-Host "[1/2] Stopping Backend Server..." -ForegroundColor Cyan
$uvicornProcesses = Get-Process | Where-Object { $_.ProcessName -like "*python*" -and $_.CommandLine -like "*uvicorn*" }

if ($uvicornProcesses) {
    $uvicornProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force
        Write-Host "   Uvicorn stopped (PID: $($_.Id))" -ForegroundColor Green
    }
} else {
    Write-Host "   No Uvicorn process running" -ForegroundColor Gray
}

# Stop Flutter processes
Write-Host "`n[2/2] Stopping Flutter App..." -ForegroundColor Cyan
$flutterProcesses = Get-Process | Where-Object { $_.ProcessName -like "*flutter*" }

if ($flutterProcesses) {
    $flutterProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force
        Write-Host "   Flutter stopped (PID: $($_.Id))" -ForegroundColor Green
    }
} else {
    Write-Host "   No Flutter process running" -ForegroundColor Gray
}

# Check Python processes (Backend)
Write-Host "`n[Additional] Checking Python processes..." -ForegroundColor Cyan
$pythonProcesses = Get-Process python -ErrorAction SilentlyContinue

if ($pythonProcesses) {
    Write-Host "   Found Python processes: $($pythonProcesses.Count)" -ForegroundColor Yellow
    Write-Host "   (Only backend-related processes are auto-stopped)" -ForegroundColor Gray
} else {
    Write-Host "   No Python process running" -ForegroundColor Gray
}

Write-Host "`nAll processes stopped!`n" -ForegroundColor Green

