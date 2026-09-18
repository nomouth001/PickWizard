# 테스트 실행 스크립트 (PowerShell)
# 2026-01-08 06:35:00 EST

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "단위 테스트 실행" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 단위 테스트만 실행 (빠름)
pytest tests/unit -m unit -v

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "통합 테스트 실행" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 통합 테스트 실행 (느림)
pytest tests/integration -m integration -v

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "전체 테스트 + 커버리지" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 전체 테스트 + 커버리지 리포트
pytest tests/ --cov=app --cov-report=html --cov-report=term-missing

Write-Host ""
Write-Host "✅ 테스트 완료!" -ForegroundColor Green
Write-Host "📊 커버리지 리포트: htmlcov/index.html" -ForegroundColor Yellow

