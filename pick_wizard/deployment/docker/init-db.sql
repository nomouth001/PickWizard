-- LuckyAI 645 데이터베이스 초기화
-- 2026-01-04 EST

-- 확장 설치
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 시간대 설정
SET timezone = 'Asia/Seoul';

-- 테이블 생성은 Alembic에서 처리
-- 여기서는 초기 설정만

-- 알고리즘 비용 초기 데이터
CREATE TABLE IF NOT EXISTS algorithm_pricing (
    id SERIAL PRIMARY KEY,
    algorithm_id INT NOT NULL UNIQUE,
    algorithm_name VARCHAR(100) NOT NULL,
    cost_per_set INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO algorithm_pricing (algorithm_id, algorithm_name, cost_per_set) VALUES
(1, '순수 랜덤', 0),
(2, 'LSTM AI', 3),
(3, '앙상블', 2),
(4, '패턴 분석', 2),
(5, '가중치 조합', 1),
(6, '빈도 기반', 1),
(7, '핫/콜드 넘버', 1),
(8, 'GAN', 5),
(9, '강화학습', 5)
ON CONFLICT (algorithm_id) DO NOTHING;

-- 초기 설정 완료 로그
DO $$
BEGIN
    RAISE NOTICE 'LuckyAI 645 Database initialized successfully at %', NOW();
END $$;

