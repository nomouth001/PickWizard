#!/usr/bin/env pwsh
# Fix Backend Dependencies
# 
# 2026-01-05 17:00:00 EST

Write-Host "`nFixing Backend Dependencies...`n" -ForegroundColor Cyan

$BackendPath = "..\..\backend"

if (-not (Test-Path $BackendPath)) {
    Write-Host "ERROR: Backend path not found" -ForegroundColor Red
    exit 1
}

Set-Location $BackendPath

# Activate venv
Write-Host "Activating venv..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1

# Install missing packages
Write-Host "`nInstalling missing packages..." -ForegroundColor Yellow
pip install psycopg2-binary

Write-Host "`nDependencies fixed!`n" -ForegroundColor Green
Write-Host "Try running the server again with:" -ForegroundColor Cyan
Write-Host "  cd pick_wizard\deployment\scripts" -ForegroundColor Gray
Write-Host "  .\run_all.ps1" -ForegroundColor Gray
Write-Host ""

