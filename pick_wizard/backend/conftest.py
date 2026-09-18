"""
Pytest 설정 파일

Python path 자동 설정
2026-01-04 EST
"""

import sys
from pathlib import Path

# backend 폴더를 Python path에 추가
backend_dir = Path(__file__).parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

