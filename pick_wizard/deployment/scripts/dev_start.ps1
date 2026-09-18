#!/usr/bin/env pwsh
# LuckyAI 645 - 개발 모드 빠른 시작 스크립트
# 
# 2026-01-05 16:50:00 EST - 초기 생성
# 
# 사용법:
#   .\dev_start.ps1 [backend|frontend|all]
#
# 예시:
#   .\dev_start.ps1           # 전체 실행 (기본값)
#   .\dev_start.ps1 backend   # 백엔드만
#   .\dev_start.ps1 frontend  # 프론트엔드만
#   .\dev_start.ps1 all       # 전체 실행

param(
    [string]$Mode = "all"
)

# Project root path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$BackendPath = Join-Path $ProjectRoot "backend"
$FrontendPath = Join-Path $ProjectRoot "mobile_app"

Write-Host "`nStarting LuckyAI 645 Dev Mode (Mode: $Mode)`n" -ForegroundColor Green

# Start Backend
if ($Mode -eq "backend" -or $Mode -eq "all") {
    Write-Host "Starting Backend Server..." -ForegroundColor Cyan
    
    $BackendScript = @"
Set-Location '$BackendPath'
`$host.UI.RawUI.WindowTitle = 'Backend - LuckyAI 645'
& '.\venv\Scripts\Activate.ps1'
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
"@
    
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $BackendScript
    Write-Host "   Backend started: http://localhost:8000" -ForegroundColor Green
    
    if ($Mode -eq "all") {
        Start-Sleep -Seconds 2
    }
}

# Start Frontend
if ($Mode -eq "frontend" -or $Mode -eq "all") {
    Write-Host "`nStarting Flutter App..." -ForegroundColor Cyan
    
    $FrontendScript = @"
Set-Location '$FrontendPath'
`$host.UI.RawUI.WindowTitle = 'Flutter - LuckyAI 645'
flutter run -d chrome
"@
    
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $FrontendScript
    Write-Host "   Flutter started" -ForegroundColor Green
}

Write-Host "`nDev environment started!`n" -ForegroundColor Green
Write-Host "To stop: Press Ctrl+C (Backend) or q (Flutter) in each window`n" -ForegroundColor Gray

