"""
Phase 0 환경 설정 자동 테스트

2026-01-04 EST - 초기 생성
"""

import pytest
import os
from pathlib import Path
import subprocess


def test_directory_structure():
    """디렉토리 구조 검증"""
    required_dirs = [
        'backend/app/api/routes',
        'backend/app/core',
        'backend/app/db/models',
        'backend/data',
        'deployment/docker',
        'shared/docs',
    ]
    
    for dir_path in required_dirs:
        assert Path(dir_path).exists(), f"필수 디렉토리 누락: {dir_path}"


def test_backend_files():
    """백엔드 필수 파일 검증"""
    required_files = [
        'backend/requirements.txt',
        'backend/.env.example',
        'backend/pyproject.toml',
        'backend/.gitignore',
        'backend/app/__init__.py',
        'backend/README.md',
    ]
    
    for file_path in required_files:
        assert Path(file_path).exists(), f"필수 파일 누락: {file_path}"


def test_docker_files():
    """Docker 설정 파일 검증"""
    required_files = [
        'deployment/docker/docker-compose.yml',
        'deployment/docker/init-db.sql',
    ]
    
    for file_path in required_files:
        assert Path(file_path).exists(), f"필수 파일 누락: {file_path}"


def test_requirements_content():
    """requirements.txt 내용 검증"""
    with open('backend/requirements.txt') as f:
        content = f.read()
        required_packages = [
            'fastapi',
            'sqlalchemy',
            'redis',
            'pandas',
            'pytest',
        ]
        
        for package in required_packages:
            assert package in content.lower(), f"필수 패키지 누락: {package}"


def test_env_example():
    """env.example 파일 필수 변수 검증"""
    env_path = Path('backend/.env.example')
    assert env_path.exists(), ".env.example 파일이 없습니다"
    
    with open(env_path) as f:
        content = f.read()
        required_vars = [
            'DATABASE_URL',
            'REDIS_URL',
            'JWT_SECRET_KEY',
            'DEBUG',
        ]
        
        for var in required_vars:
            assert var in content, f"필수 환경 변수 누락: {var}"


def test_git_initialization():
    """Git 저장소 초기화 검증"""
    assert Path('.git').exists(), "Git 저장소가 초기화되지 않았습니다"
    
    # 브랜치 확인
    result = subprocess.run(
        ['git', 'branch'],
        capture_output=True,
        text=True,
        check=True
    )
    
    branches = result.stdout
    assert 'master' in branches or 'main' in branches, "메인 브랜치가 없습니다"


def test_gitignore():
    """.gitignore 파일 검증"""
    gitignore_files = [
        '.gitignore',
        'backend/.gitignore',
    ]
    
    for gitignore in gitignore_files:
        assert Path(gitignore).exists(), f"gitignore 파일 누락: {gitignore}"


def test_readme_exists():
    """README.md 파일 검증"""
    readme_files = [
        'README.md',
        'backend/README.md',
    ]
    
    for readme in readme_files:
        assert Path(readme).exists(), f"README 파일 누락: {readme}"
        
        with open(readme) as f:
            content = f.read()
            assert len(content) > 100, f"{readme} 파일 내용이 너무 짧습니다"


def test_init_files():
    """__init__.py 파일 검증"""
    init_dirs = [
        'backend/app',
        'backend/app/api',
        'backend/app/core',
        'backend/app/db',
        'backend/app/algorithms',
    ]
    
    for dir_path in init_dirs:
        init_file = Path(dir_path) / '__init__.py'
        assert init_file.exists(), f"__init__.py 파일 누락: {init_file}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

