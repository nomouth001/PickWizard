"""
캐시 매니저 - Redis 캐싱

2026-01-04 EST - 초기 생성
"""

import json
from typing import Optional, Any
from redis import Redis
from loguru import logger

from app.config import settings


class CacheManager:
    """Redis 캐시 관리"""
    
    def __init__(self):
        self.redis: Optional[Redis] = None
        self.default_ttl = settings.CACHE_TTL
    
    def connect(self):
        """Redis 연결"""
        try:
            self.redis = Redis.from_url(
                settings.REDIS_URL,
                decode_responses=True
            )
            self.redis.ping()
            logger.info("[INFO] Redis 연결 성공")
        except Exception as e:
            logger.error(f"Redis 연결 실패: {e}")
            self.redis = None
    
    def get(self, key: str) -> Optional[Any]:
        """캐시 조회"""
        if not self.redis:
            return None
        
        try:
            value = self.redis.get(key)
            if value:
                return json.loads(value)
            return None
        except Exception as e:
            logger.error(f"캐시 조회 오류 ({key}): {e}")
            return None
    
    def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """
        캐시 저장
        
        Args:
            key: 캐시 키
            value: 저장할 값
            ttl: 만료 시간 (초), None이면 기본값 사용
        """
        if not self.redis:
            return
        
        try:
            ttl_to_use = ttl if ttl is not None else self.default_ttl
            self.redis.setex(
                key,
                ttl_to_use,
                json.dumps(value, ensure_ascii=False, default=str)
            )
            logger.debug(f"캐시 저장: {key} (TTL={ttl_to_use}s)")
        except Exception as e:
            logger.error(f"캐시 저장 오류 ({key}): {e}")
    
    def delete(self, key: str):
        """캐시 삭제"""
        if not self.redis:
            return
        
        try:
            self.redis.delete(key)
            logger.debug(f"캐시 삭제: {key}")
        except Exception as e:
            logger.error(f"캐시 삭제 오류 ({key}): {e}")
    
    def clear_pattern(self, pattern: str):
        """패턴 매칭 캐시 삭제"""
        if not self.redis:
            return
        
        try:
            keys = self.redis.keys(pattern)
            if keys:
                self.redis.delete(*keys)
                logger.info(f"캐시 삭제: {len(keys)}개 ({pattern})")
        except Exception as e:
            logger.error(f"패턴 캐시 삭제 오류 ({pattern}): {e}")
    
    def exists(self, key: str) -> bool:
        """캐시 존재 여부 확인"""
        if not self.redis:
            return False
        
        try:
            return self.redis.exists(key) > 0
        except Exception as e:
            logger.error(f"캐시 확인 오류 ({key}): {e}")
            return False


# 전역 인스턴스
cache_manager = CacheManager()

