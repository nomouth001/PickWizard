"""
가격 정책 서비스 (Pricing Service)

YAML 설정 파일 기반 유연한 과금 모델 관리

2026-01-08 03:32:00 EST - 초기 생성
"""

import os
from datetime import datetime, date
from typing import Dict, Optional, Any
from pathlib import Path

import yaml
from loguru import logger


class PricingService:
    """
    가격 정책 관리 서비스
    
    - YAML 파일에서 가격 정책 로드
    - 알고리즘별, 세트별 가격 계산
    - 할인, 이벤트 가격 적용
    - 향후 DB 연동 가능하도록 인터페이스 설계
    """
    
    def __init__(self, config_path: Optional[str] = None):
        """
        Args:
            config_path: YAML 설정 파일 경로 (기본: app/config/pricing_config.yaml)
        """
        if config_path is None:
            # 기본 경로
            base_dir = Path(__file__).parent.parent
            config_path = base_dir / "config" / "pricing_config.yaml"
        
        self.config_path = Path(config_path)
        self.config: Dict[str, Any] = {}
        self.current_policy: Dict[str, Any] = {}
        
        self._load_config()
    
    def _load_config(self):
        """YAML 설정 파일 로드"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                self.config = yaml.safe_load(f)
            
            # 기본 정책 로드
            default_policy_name = self.config.get('default_policy', 'standard')
            self._set_policy(default_policy_name)
            
            logger.info(f"[INFO] 가격 정책 로드 완료: {default_policy_name}")
            
        except FileNotFoundError:
            logger.error(f"[ERROR] 가격 설정 파일 없음: {self.config_path}")
            self._use_fallback_config()
        except yaml.YAMLError as e:
            logger.error(f"[ERROR] YAML 파싱 오류: {e}")
            self._use_fallback_config()
    
    def _use_fallback_config(self):
        """폴백 설정 (파일 로드 실패 시)"""
        logger.warning("[WARN] 폴백 가격 정책 사용 (모든 알고리즘 무료)")
        self.current_policy = {
            'name': '폴백 정책',
            'algorithm_costs': {i: 0 for i in range(1, 10)},
            'volume_discount': {'enabled': False},
            'daily_free_quota': {'enabled': False}
        }
    
    def _set_policy(self, policy_name: str):
        """특정 정책 활성화"""
        policies = self.config.get('policies', {})
        
        if policy_name not in policies:
            logger.warning(f"[WARN] 정책 '{policy_name}' 없음, 표준 정책 사용")
            policy_name = 'standard'
        
        self.current_policy = policies.get(policy_name, {})
        logger.debug(f"정책 '{policy_name}' 활성화")
    
    def reload_config(self):
        """설정 파일 재로드 (hot-reload)"""
        logger.info("가격 설정 재로드 중...")
        self._load_config()
    
    def get_algorithm_cost(self, algorithm_id: int) -> int:
        """
        알고리즘 세트당 비용 조회
        
        Args:
            algorithm_id: 알고리즘 ID
            
        Returns:
            세트당 코인 비용
        """
        costs = self.current_policy.get('algorithm_costs', {})
        cost = costs.get(algorithm_id, 0)
        
        # 특별 이벤트 확인
        event_discount = self._get_event_discount(algorithm_id)
        if event_discount > 0:
            cost = int(cost * (1 - event_discount))
        
        return cost
    
    def calculate_total_cost(
        self,
        algorithm_id: int,
        n_sets: int,
        user_subscription: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        총 비용 계산
        
        Args:
            algorithm_id: 알고리즘 ID
            n_sets: 생성할 세트 수
            user_subscription: 사용자 구독 플랜 ID (옵션)
            
        Returns:
            {
                'base_cost': 기본 비용,
                'discount_amount': 할인 금액,
                'final_cost': 최종 비용,
                'discount_reason': 할인 사유,
                'breakdown': 세부 내역
            }
        """
        # 1. 기본 비용 계산
        cost_per_set = self.get_algorithm_cost(algorithm_id)
        base_cost = cost_per_set * n_sets
        
        # 2. 구독자는 무료
        if user_subscription:
            return {
                'base_cost': base_cost,
                'discount_amount': base_cost,
                'final_cost': 0,
                'discount_reason': f'구독 플랜: {user_subscription}',
                'breakdown': {
                    'algorithm_id': algorithm_id,
                    'n_sets': n_sets,
                    'cost_per_set': 0,
                    'subscription': user_subscription
                }
            }
        
        # 3. 볼륨 할인 적용
        discount_amount = 0
        discount_reason = None
        
        volume_discount_config = self.current_policy.get('volume_discount', {})
        if volume_discount_config.get('enabled', False):
            discount_rate = self._get_volume_discount_rate(n_sets, volume_discount_config)
            if discount_rate > 0:
                discount_amount = int(base_cost * discount_rate)
                discount_reason = f'볼륨 할인 {int(discount_rate * 100)}%'
        
        # 4. 최종 비용
        final_cost = max(0, base_cost - discount_amount)
        
        # 5. 최소/최대 청구 금액 적용
        pricing_rules = self.config.get('pricing_rules', {})
        min_charge = pricing_rules.get('minimum_charge', 0)
        max_charge = pricing_rules.get('maximum_charge', 1000)
        
        final_cost = max(min_charge, min(max_charge, final_cost))
        
        return {
            'base_cost': base_cost,
            'discount_amount': discount_amount,
            'final_cost': final_cost,
            'discount_reason': discount_reason,
            'breakdown': {
                'algorithm_id': algorithm_id,
                'n_sets': n_sets,
                'cost_per_set': cost_per_set
            }
        }
    
    def _get_volume_discount_rate(
        self,
        n_sets: int,
        discount_config: Dict
    ) -> float:
        """볼륨 할인율 계산"""
        tiers = discount_config.get('tiers', [])
        
        for tier in tiers:
            min_sets = tier.get('min_sets', 0)
            max_sets = tier.get('max_sets')
            
            if max_sets is None:
                # 무제한 (마지막 티어)
                if n_sets >= min_sets:
                    return tier.get('discount', 0.0)
            else:
                if min_sets <= n_sets <= max_sets:
                    return tier.get('discount', 0.0)
        
        return 0.0
    
    def _get_event_discount(self, algorithm_id: int) -> float:
        """특별 이벤트 할인율 조회"""
        special_events = self.config.get('special_events', [])
        today = date.today()
        current_weekday = today.weekday()
        
        for event in special_events:
            if not event.get('enabled', False):
                continue
            
            # 기간 확인
            start_date = event.get('start_date')
            end_date = event.get('end_date')
            
            if start_date and end_date:
                start = datetime.strptime(start_date, '%Y-%m-%d').date()
                end = datetime.strptime(end_date, '%Y-%m-%d').date()
                
                if not (start <= today <= end):
                    continue
            
            # 요일 확인 (주말 특가 등)
            days_of_week = event.get('days_of_week')
            if days_of_week and current_weekday not in days_of_week:
                continue
            
            # 알고리즘 확인
            applies_to = event.get('applies_to_algorithms', [])
            if algorithm_id not in applies_to:
                continue
            
            # 할인율 반환
            discount_percent = event.get('discount_percent', 0)
            return discount_percent / 100.0
        
        return 0.0
    
    def get_policy_info(self) -> Dict[str, Any]:
        """현재 정책 정보 반환"""
        return {
            'name': self.current_policy.get('name', 'Unknown'),
            'description': self.current_policy.get('description', ''),
            'algorithm_costs': self.current_policy.get('algorithm_costs', {}),
            'version': self.config.get('version', '1.0.0'),
            'last_updated': self.config.get('last_updated', 'Unknown')
        }
    
    def get_all_policies(self) -> Dict[str, Any]:
        """모든 정책 목록 반환"""
        policies = self.config.get('policies', {})
        return {
            name: {
                'name': policy.get('name'),
                'description': policy.get('description'),
                'enabled': policy.get('enabled', False)
            }
            for name, policy in policies.items()
        }
    
    def switch_policy(self, policy_name: str) -> bool:
        """
        정책 전환 (관리자용)
        
        Args:
            policy_name: 전환할 정책 이름
            
        Returns:
            성공 여부
        """
        policies = self.config.get('policies', {})
        
        if policy_name not in policies:
            logger.error(f"[ERROR] 정책 '{policy_name}' 없음")
            return False
        
        self._set_policy(policy_name)
        logger.info(f"[INFO] 정책 전환: {policy_name}")
        return True


# 싱글톤 인스턴스
_pricing_service: Optional[PricingService] = None


def get_pricing_service() -> PricingService:
    """
    가격 정책 서비스 싱글톤 인스턴스 반환
    
    Returns:
        PricingService 인스턴스
    """
    global _pricing_service
    
    if _pricing_service is None:
        _pricing_service = PricingService()
    
    return _pricing_service


def reload_pricing_config():
    """가격 설정 재로드 (hot-reload용)"""
    global _pricing_service
    
    if _pricing_service:
        _pricing_service.reload_config()
    else:
        _pricing_service = PricingService()

