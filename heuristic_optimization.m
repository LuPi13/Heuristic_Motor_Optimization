function min_vector = heuristic_optimization(x)
    % Differential Evolution Algorithm(DE; 차분진화 알고리즘)
    % x: input vector; 각 요소의 최소/최대값을 nx2 행렬로 입력
    % example: x = [1 2; 3 4; 5 6]; 1<=x1<=2, 3<=x2<=4, 5<=x3<=6
    % min_vector: 최적화된 벡터; 각 요소의 최소값을 1xn 행렬로 출력

    tic; % 시작 시간 기록
    
    %% 파라미터 설정
    P = 100; % P: Population size; 연산 시간에 비례. 차원*10 권장
    G = 100; % G: Generation size; 연산 시간에 비례. 300~500 권장
    F = 0.5; % F: Mutation factor; 0 < F < 1
    CR = 0.9; % CR: Crossover rate; 0 < CR < 1

    dimension = size(x, 1); % dimension: number of variables
    population = zeros(P, dimension); % 초기화된 개체군
    indiv_result = zeros(P, 1); % 개체군의 결과값 초기화


    %% 첫 개체군 생성; 랜덤
    for i = 1:P
        volunteer = zeros(1, dimension); % 개체 초기화
        is_valid = false; % 유효성 검사 플래그
        while ~is_valid
            for d = 1:dimension
                volunteer(1, d) = x(d, 1) + (x(d, 2) - x(d, 1)) * rand(); % 범위 내 랜덤 값 생성
            end
            result = objective_function(get_TR(volunteer)); % 결과값 계산

            if result < 1e10 % 유효한 개체인지 검사
                population(i, :) = volunteer; % 유효한 개체군에 추가
                indiv_result(i) = result; % 결과값 저장
                is_valid = true; % 유효성 플래그 설정
            end
        end
        fprintf('Individual %d generated.\n', i); % 개체 생성 완료 메시지 출력
        fprintf('Time elapsed: %.2f s\n', toc); % 경과 시간 출력
        fprintf('\n');
    end


    [best_cost, best_index] = min(indiv_result); % 최적 비용과 인덱스 초기화
    best_vector = population(best_index, :); % 최적 벡터

    fprintf('Initial Population generated.\n');
    fprintf('Time elapsed: %.2f s\n', toc); % 경과 시간 출력
    fprintf('\n')


    %% 세대 반복
    for gen = 1:G

        % Mutation
        for i = 1:P
            idxs = randperm(P); % 랜덤 인덱스 생성
            idxs(idxs == i) = []; % 현재 개체 제거

            x1 = population(idxs(1), :); % 첫 번째 개체
            x2 = population(idxs(2), :); % 두 번째 개체

            mutant = best_vector + F * (x1 - x2); % 변이 벡터 생성
        
            % 변이 벡터의 각 요소를 최소/최대값으로 제한
            for d = 1:dimension
                if mutant(d) < x(d, 1)
                    mutant(d) = x(d, 1); % 최소값으로 설정
                elseif mutant(d) > x(d, 2)
                    mutant(d) = x(d, 2); % 최대값으로 설정
                end
            end


            % Crossover
            target = population(i, :); % 현재 개체
            trial = target; % 다음세대 개체
            j_rand = randi(dimension); % 반드시 변경할 인덱스 생성

            for d = 1:dimension
                if rand(1) < CR || d == j_rand % CR확률 또는 무작위 인덱스에 해당하면
                    trial(d) = mutant(d); % 변이 벡터에서 값 가져오기
                end
            end


            % Selection
            trial_cost = objective_function(get_TR(target)); % trial 벡터의 결과값 계산
            if trial_cost < indiv_result(i) % trial 벡터가 더 좋으면
                population(i, :) = trial; % 현재 개체를 trial로 대체
                indiv_result(i) = trial_cost; % 결과값 업데이트

                if trial_cost < best_cost % trial 벡터가 최적 벡터보다 더 좋으면
                    best_cost = trial_cost; % 최적 비용 업데이트
                    best_vector = trial; % 최적 벡터 업데이트
                end
            end
        end
        elapsed_time = toc; % 경과 시간 기록
        fprintf('Time elapsed: %.2f s\n', elapsed_time);
        fprintf('Generation %d: Best Cost = %.4f\n', gen, best_cost); % 세대별 결과 출력
        fprintf('Best Vector: ');
        fprintf('%.4f ', best_vector); % 최적 벡터 출력
        fprintf('\n');
    end
    min_vector = best_vector;
end