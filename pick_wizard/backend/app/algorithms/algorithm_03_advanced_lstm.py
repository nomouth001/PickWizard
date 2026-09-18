"""
Algorithm 3: LSTM 고급 분석 (Advanced LSTM)

LSTM 학습 + 다양한 전략 (학습 방식 × 확률 방식)

2026-01-07 EST - 초기 생성 (010.2_Algorithm_Redesign_LSTM.md 기반)
2026-01-08 05:40:00 EST - 중복 제거: base 클래스 메서드 사용
"""

import os
import glob
from datetime import datetime
from typing import List, Dict, Optional, Any, Literal, Tuple

import numpy as np
import pandas as pd

from app.algorithms.base import LottoAlgorithm

# PyTorch는 선택적 의존성
try:
    import torch
    import torch.nn as nn
    import torch.optim as optim
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False
    torch = None
    nn = None
    optim = None


# =====================================
# LSTM 모델 정의
# =====================================

if TORCH_AVAILABLE:
    class LottoLSTM(nn.Module):
        """로또 번호 예측 LSTM 모델"""
        
        def __init__(
            self,
            input_size: int = 45,
            hidden_size: int = 128,
            num_layers: int = 2,
            dropout: float = 0.2
        ):
            super(LottoLSTM, self).__init__()
            
            self.lstm = nn.LSTM(
                input_size=input_size,
                hidden_size=hidden_size,
                num_layers=num_layers,
                dropout=dropout if num_layers > 1 else 0.0,
                batch_first=True
            )
            
            self.fc = nn.Linear(hidden_size, input_size)
            self.sigmoid = nn.Sigmoid()
        
        def forward(self, x):
            out, _ = self.lstm(x)
            out = out[:, -1, :]
            out = self.fc(out)
            out = self.sigmoid(out)
            return out


# =====================================
# 데이터 전처리
# =====================================

def numbers_to_onehot(numbers: List[int]) -> np.ndarray:
    """로또 번호 → 45차원 원-핫 벡터"""
    onehot = np.zeros(45, dtype=np.float32)
    for num in numbers:
        onehot[num - 1] = 1.0
    return onehot


def create_sequences(
    historical_data: pd.DataFrame,
    window_size: int
) -> Tuple[np.ndarray, np.ndarray]:
    """Sliding window로 학습 데이터 생성"""
    onehots = []
    for idx, row in historical_data.iterrows():
        numbers = [row[f'num{i}'] for i in range(1, 7)]
        onehot = numbers_to_onehot(numbers)
        onehots.append(onehot)
    
    onehots = np.array(onehots)
    
    X, y = [], []
    for i in range(len(onehots) - window_size):
        X.append(onehots[i:i+window_size])
        y.append(onehots[i+window_size])
    
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


# =====================================
# 학습 함수
# =====================================

def train_lstm(
    model,
    X_train: np.ndarray,
    y_train: np.ndarray,
    num_epochs: int = 50,
    learning_rate: float = 0.001,
    batch_size: int = 32,
    device: str = 'cpu'
):
    """LSTM 모델 학습"""
    if not TORCH_AVAILABLE:
        raise RuntimeError("PyTorch가 설치되지 않았습니다")
    
    model = model.to(device)
    model.train()
    
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)
    
    X_tensor = torch.FloatTensor(X_train).to(device)
    y_tensor = torch.FloatTensor(y_train).to(device)
    
    n_samples = len(X_train)
    
    for epoch in range(num_epochs):
        epoch_loss = 0.0
        indices = np.random.permutation(n_samples)
        
        for i in range(0, n_samples, batch_size):
            batch_indices = indices[i:i+batch_size]
            X_batch = X_tensor[batch_indices]
            y_batch = y_tensor[batch_indices]
            
            outputs = model(X_batch)
            loss = criterion(outputs, y_batch)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            epoch_loss += loss.item()
        
        if (epoch + 1) % 10 == 0:
            avg_loss = epoch_loss / max(1, (n_samples // batch_size))
            print(f"[LSTM] Epoch {epoch+1}/{num_epochs}, Loss: {avg_loss:.4f}")
    
    return model


def predict_probabilities(
    model,
    historical_data: pd.DataFrame,
    window_size: int,
    device: str = 'cpu'
) -> Dict[int, float]:
    """LSTM으로 확률 예측"""
    if not TORCH_AVAILABLE:
        raise RuntimeError("PyTorch가 설치되지 않았습니다")
    
    model = model.to(device)
    model.eval()
    
    recent = historical_data.tail(window_size)
    
    onehots = []
    for idx, row in recent.iterrows():
        numbers = [row[f'num{i}'] for i in range(1, 7)]
        onehot = numbers_to_onehot(numbers)
        onehots.append(onehot)
    
    X = np.array([onehots], dtype=np.float32)
    X_tensor = torch.FloatTensor(X).to(device)
    
    with torch.no_grad():
        probs = model(X_tensor)
        probs = probs.cpu().numpy()[0]
    
    probabilities = {i+1: float(probs[i]) for i in range(45)}
    
    return probabilities


# =====================================
# 모델 저장/로드 (Cumulative용)
# =====================================

MODEL_DIR = "backend/app/models/lstm_checkpoints"


def save_model(
    model,
    round_number: int,
    hidden_size: int,
    num_layers: int,
    dropout: float
):
    """모델 체크포인트 저장"""
    if not TORCH_AVAILABLE:
        return
    
    os.makedirs(MODEL_DIR, exist_ok=True)
    path = f"{MODEL_DIR}/lstm_model_round_{round_number}.pth"
    
    torch.save({
        'model_state_dict': model.state_dict(),
        'round_number': round_number,
        'hidden_size': hidden_size,
        'num_layers': num_layers,
        'dropout': dropout,
        'timestamp': datetime.now().isoformat()
    }, path)
    
    print(f"[LSTM] 모델 저장: {path}")


def load_latest_model(
    hidden_size: int,
    num_layers: int,
    dropout: float
) -> Tuple[Optional[Any], Optional[int]]:
    """가장 최신 모델 로드"""
    if not TORCH_AVAILABLE:
        return None, None
    
    if not os.path.exists(MODEL_DIR):
        return None, None
    
    checkpoints = glob.glob(f"{MODEL_DIR}/lstm_model_round_*.pth")
    
    if not checkpoints:
        return None, None
    
    latest = max(checkpoints, 
                 key=lambda x: int(x.split('_')[-1].split('.')[0]))
    
    checkpoint = torch.load(latest, map_location='cpu')
    round_number = checkpoint['round_number']
    
    model = LottoLSTM(
        input_size=45,
        hidden_size=checkpoint.get('hidden_size', hidden_size),
        num_layers=checkpoint.get('num_layers', num_layers),
        dropout=checkpoint.get('dropout', dropout)
    )
    model.load_state_dict(checkpoint['model_state_dict'])
    
    print(f"[LSTM] 모델 로드: 회차 {round_number}")
    
    return model, round_number


# =====================================
# 통합 알고리즘 클래스
# =====================================

class AdvancedLSTMAlgorithm(LottoAlgorithm):
    """
    알고리즘 3: LSTM 고급 분석 (통합 버전)
    
    학습 방식 × 확률 방식 = 4가지 조합
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=3,
            # 2026-01-17 18:30:00 EST - "LSTM 고급 분석" -> "딥러닝 선택" 변경
            # 사유: 일반 사용자 이해도 향상, "선택" 용어로 로또 맥락 명확화
            name="딥러닝 선택 (Deep Learning Selection)",
            description="LSTM 학습 + 다양한 전략 (학습 방식 × 확률 방식)"
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=3  # 기본값 (파라미터로 조정)
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        
        # A. 학습 방식 [LEARNING_MODE]
        learning_mode: Literal['non-cumulative', 'cumulative'] = 'non-cumulative',
        
        # B. 확률 방식 [PROBABILITY_MODE]
        probability_mode: Literal['normal', 'inverse'] = 'normal',
        
        # C. 학습 범위
        window_size: int = 100,
        
        # D. 모델 구조
        hidden_size: int = 128,
        num_layers: int = 2,
        dropout: float = 0.2,
        
        # E. 학습 설정
        num_epochs: int = 50,
        learning_rate: float = 0.001,
        batch_size: int = 32,
        
        # F. 추가 옵션
        apply_recent_penalty: bool = False,
        penalty_rate: float = 0.5,
        temperature: float = 1.0,
        
        # 디바이스
        device: str = 'cpu',
        
        **kwargs
    ) -> List[List[int]]:
        """LSTM 고급 분석 번호 생성 (통합 버전)"""
        
        # PyTorch 확인
        if not TORCH_AVAILABLE:
            raise RuntimeError(
                "LSTM 알고리즘을 사용하려면 PyTorch가 필요합니다. "
                "pip install torch를 실행하세요."
            )
        
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(
            n_sets, exclude_numbers, include_numbers
        )
        if not valid:
            raise ValueError(error_msg)
        
        # 2026-01-17 19:30:00 EST - window_size 9999 처리 (전회차)
        # UI에서 "전체" 선택 시 9999로 전달됨
        effective_window_size = window_size
        if window_size >= 9999:
            effective_window_size = len(historical_data) - 10
            print(f"[알고리즘 3] 전회차 모드: window_size를 {effective_window_size}로 설정")
        
        if historical_data is None or len(historical_data) < effective_window_size + 10:
            raise ValueError(f"최소 {effective_window_size + 10}회차 이상의 데이터 필요")
        
        # 현재 최신 회차
        current_round = historical_data.iloc[-1]['round']
        
        # ===== 1. 학습 방식에 따라 분기 =====
        
        if learning_mode == 'non-cumulative':
            # Non-Cumulative: 전체 학습
            print(f"[알고리즘 3] Non-Cumulative 학습 시작")
            
            X_train, y_train = create_sequences(historical_data, effective_window_size)
            
            model = LottoLSTM(
                input_size=45,
                hidden_size=hidden_size,
                num_layers=num_layers,
                dropout=dropout
            )
            
            model = train_lstm(
                model, X_train, y_train,
                num_epochs=num_epochs,
                learning_rate=learning_rate,
                batch_size=batch_size,
                device=device
            )
        
        else:  # 'cumulative'
            # Cumulative: 증분 학습
            print(f"[알고리즘 3] Cumulative 학습 시작")
            
            # 기존 모델 로드
            model, last_round = load_latest_model(
                hidden_size, num_layers, dropout
            )
            
            if model is None:
                # 처음 학습
                print(f"[알고리즘 3] 초기 학습 (전체 데이터)")
                model = LottoLSTM(
                    input_size=45,
                    hidden_size=hidden_size,
                    num_layers=num_layers,
                    dropout=dropout
                )
                training_data = historical_data
                last_round = 0
            else:
                # 증분 학습
                print(f"[알고리즘 3] 증분 학습 (회차 {last_round+1} ~ {current_round})")
                training_data = historical_data[
                    historical_data['round'] > last_round
                ]
            
            # 신규 데이터로 학습
            if len(training_data) >= effective_window_size + 1:
                X_train, y_train = create_sequences(training_data, effective_window_size)
                
                if len(X_train) > 0:
                    # Cumulative는 epochs 짧게
                    model = train_lstm(
                        model, X_train, y_train,
                        num_epochs=min(num_epochs, 20),
                        learning_rate=learning_rate,
                        batch_size=batch_size,
                        device=device
                    )
                    
                    # 모델 저장
                    save_model(
                        model, current_round,
                        hidden_size, num_layers, dropout
                    )
        
        # ===== 2. 확률 예측 =====
        probabilities = predict_probabilities(
            model, historical_data, effective_window_size, device
        )
        
        # 제외 번호 필터링
        if exclude_numbers:
            for num in exclude_numbers:
                probabilities.pop(num, None)
        
        if include_numbers:
            for num in include_numbers:
                probabilities.pop(num, None)
        
        # ===== 3. 확률 방식에 따라 분기 [PROBABILITY_MODE] =====
        
        if probability_mode == 'inverse':
            # 역확률 변환
            probabilities = self._apply_inverse_probability(probabilities)
        
        # ===== 4. 추가 옵션 적용 =====
        
        # 직전 회차 패널티
        # 2026-01-08 05:40:00 EST - base 클래스 정적 메서드 사용
        if apply_recent_penalty:
            probabilities = self.apply_recent_draw_penalty(
                probabilities, historical_data, penalty_rate
            )
        
        # 온도 조정
        # 2026-01-08 05:40:00 EST - base 클래스 정적 메서드 사용
        probabilities = self.apply_temperature(probabilities, temperature)
        
        # ===== 5. 번호 생성 =====
        results = []
        numbers_list = list(probabilities.keys())
        probs_list = list(probabilities.values())
        
        # 정규화
        probs_sum = sum(probs_list)
        if probs_sum > 0:
            probs_list = [p / probs_sum for p in probs_list]
        else:
            probs_list = [1.0 / len(probs_list)] * len(probs_list)
        
        for _ in range(n_sets):
            selected = []
            
            if include_numbers:
                selected.extend(include_numbers)
            
            remaining = 6 - len(selected)
            if remaining > 0:
                chosen = np.random.choice(
                    numbers_list,
                    size=remaining,
                    replace=False,
                    p=probs_list
                )
                selected.extend(chosen.tolist())
            
            results.append(sorted(selected))
        
        return results
    
    def _apply_inverse_probability(
        self,
        probabilities: Dict[int, float]
    ) -> Dict[int, float]:
        """역확률 변환 [INVERSE]"""
        if not probabilities:
            return probabilities
        
        max_prob = max(probabilities.values())
        epsilon = 0.01
        
        inverse = {
            num: max_prob - prob + epsilon 
            for num, prob in probabilities.items()
        }
        
        total = sum(inverse.values())
        if total > 0:
            inverse = {num: inv / total for num, inv in inverse.items()}
        
        return inverse
    
    # 2026-01-08 05:40:00 EST - _apply_recent_draw_penalty 삭제 (base 클래스로 이동)
    # 2026-01-08 05:40:00 EST - _apply_temperature 삭제 (base 클래스로 이동)
    
    def calculate_cost(
        self,
        learning_mode: str,
        probability_mode: str,
        hidden_size: int = 128,
        num_epochs: int = 50
    ) -> int:
        """파라미터 조합에 따른 비용 계산"""
        # 기본 비용
        base_cost = {
            ('non-cumulative', 'normal'): 3,
            ('non-cumulative', 'inverse'): 4,
            ('cumulative', 'normal'): 2,
            ('cumulative', 'inverse'): 5
        }
        
        cost = base_cost.get((learning_mode, probability_mode), 3)
        
        # 추가 비용
        if hidden_size >= 256:
            cost += 1
        if num_epochs >= 100:
            cost += 1
        
        return cost
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'learning_mode': 'non-cumulative',
            'probability_mode': 'normal',
            'window_size': 100,
            'hidden_size': 128,
            'num_layers': 2,
            'dropout': 0.2,
            'num_epochs': 50,
            'learning_rate': 0.001,
            'batch_size': 32,
            'apply_recent_penalty': False,
            'penalty_rate': 0.5,
            'temperature': 1.0,
            'device': 'cpu'
        }

