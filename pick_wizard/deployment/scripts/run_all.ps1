#!/usr/bin/env pwsh
# LuckyAI 645 - 백엔드 + 프론트엔드 통합 실행 스크립트
# 
# 2026-01-05 16:50:00 EST - 초기 생성
# 
# 사용법:
#   .\run_all.ps1
#   또는
#   pwsh .\run_all.ps1

# 색상 출력 함수
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 프로젝트 루트 경로
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Write-Host "Project Root: $ProjectRoot" -ForegroundColor Cyan

# Backend path
$BackendPath = Join-Path $ProjectRoot "backend"
# Frontend path
$FrontendPath = Join-Path $ProjectRoot "mobile_app"

Write-Host "`nStarting LuckyAI 645...`n" -ForegroundColor Green

# Check paths
if (-not (Test-Path $BackendPath)) {
    Write-Host "ERROR: Backend path not found: $BackendPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $FrontendPath)) {
    Write-Host "ERROR: Frontend path not found: $FrontendPath" -ForegroundColor Red
    exit 1
}

# Check Python venv (Backend)
$VenvPath = Join-Path $BackendPath "venv"
$VenvActivate = Join-Path $VenvPath "Scripts\Activate.ps1"

if (-not (Test-Path $VenvActivate)) {
    Write-Host "WARNING: Python venv not found." -ForegroundColor Yellow
    Write-Host "Create venv now? (y/n): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "Creating venv..." -ForegroundColor Cyan
        Set-Location $BackendPath
        python -m venv venv
        & $VenvActivate
        pip install -r requirements.txt
        Write-Host "Venv created successfully" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Venv required. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Check Flutter installation
$FlutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $FlutterCheck) {
    Write-Host "ERROR: Flutter not found. Please install Flutter and add to PATH." -ForegroundColor Red
    exit 1
}

Write-Host "`nAll checks passed`n" -ForegroundColor Green

# 1. Start Backend Server (new PowerShell window)
Write-Host "[1/2] Starting Backend FastAPI Server..." -ForegroundColor Cyan

$BackendScript = @"
Set-Location '$BackendPath'
`$host.UI.RawUI.WindowTitle = 'LuckyAI 645 - Backend Server'
Write-Host 'Starting Backend Server...' -ForegroundColor Cyan
Write-Host 'Path: $BackendPath' -ForegroundColor Gray
Write-Host ''

# Activate venv
& '$VenvActivate'
Write-Host 'Venv activated' -ForegroundColor Green

# Start Uvicorn server
Write-Host ''
Write-Host 'FastAPI Server Running...' -ForegroundColor Green
Write-Host '   URL: http://localhost:8000' -ForegroundColor Yellow
Write-Host '   Docs: http://localhost:8000/docs' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Press Ctrl+C to stop' -ForegroundColor Gray
Write-Host ''

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
"@

Start-Process pwsh -ArgumentList "-NoExit", "-Command", $BackendScript

Write-Host "   Backend started (new window)" -ForegroundColor Green
Start-Sleep -Seconds 3

# 2. Start Flutter App (new PowerShell window)
Write-Host "`n[2/2] Starting Flutter App..." -ForegroundColor Cyan

$FrontendScript = @"
Set-Location '$FrontendPath'
`$host.UI.RawUI.WindowTitle = 'LuckyAI 645 - Flutter App'
Write-Host 'Starting Flutter App...' -ForegroundColor Cyan
Write-Host 'Path: $FrontendPath' -ForegroundColor Gray
Write-Host ''

# Check Flutter dependencies
Write-Host 'Checking Flutter dependencies...' -ForegroundColor Yellow
flutter pub get

Write-Host ''
Write-Host 'Flutter App Running on Chrome...' -ForegroundColor Green
Write-Host ''
Write-Host 'Hot Reload: r' -ForegroundColor Yellow
Write-Host 'Hot Restart: R' -ForegroundColor Yellow
Write-Host 'Quit: q' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Note: Using Chrome for development (fast & easy)' -ForegroundColor Gray
Write-Host 'For Windows desktop app, install Visual Studio 2022' -ForegroundColor Gray
Write-Host ''

flutter run -d chrome
"@

Start-Process pwsh -ArgumentList "-NoExit", "-Command", $FrontendScript

Write-Host "   Flutter started (new window)" -ForegroundColor Green

# Complete message
Write-Host "`n" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "  SUCCESS! LuckyAI 645 Running" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "Running Services:" -ForegroundColor Cyan
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor Yellow
Write-Host "  API Docs: http://localhost:8000/docs" -ForegroundColor Yellow
Write-Host "  Flutter:  App Running..." -ForegroundColor Yellow
Write-Host "" -ForegroundColor White
Write-Host "Tips:" -ForegroundColor Cyan
Write-Host "  - Each service runs in separate window" -ForegroundColor Gray
Write-Host "  - Backend: Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host "  - Flutter: Press q to quit" -ForegroundColor Gray
Write-Host "" -ForegroundColor White
Write-Host "You can close this window. Services will continue running." -ForegroundColor Gray
Write-Host "" -ForegroundColor White

# Auto close after 5 seconds
Write-Host "Closing in 5 seconds..." -ForegroundColor DarkGray
Start-Sleep -Seconds 5

