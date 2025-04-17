function cost = objective_function(TR)
    % 모터의 목적함수
    % 큰 토크와 작은 리플을 목표로 함
    % TR: [T R]의 형태로 입력됨
    % T: 토크[Nm], R: 리플[%]
    % cost: 목적함수의 값

    T = TR(1); % 토크
    R = TR(2); % 리플
    
    w_T = 0.8; % 토크 가중치
    w_R = 0.2; % 리플 가중치
    lambda_R = 1; % 리플이 10% 이상일 경우 페널티 가중치

    ref_T = 10.0; % 토크 예상치
    ref_R = 10; % 리플 예상치

    cost = -w_T * (T / ref_T) + w_R * (R / ref_R) + lambda_R * (R > 10) * (R - 10)^2;