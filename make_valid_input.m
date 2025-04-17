function result = make_valid_input(x)
    % 유효한 입력을 생성하는 함수입니다.
    % 해당 프로젝트의 경우, 유효한 모터로 변수를 재설정합니다.
    % x: 변수의 최대/최소 정보

    % x1: depth[0..200], x2: r_so[0..300], x3: r_si[0..300],x4: th_core[0..10], x5: w_teeth[0..150], x6: slot_ratio[0..1]
    % x7: shoe_1[0..100], x8: shoe_2[0..100], x9: c_w[0..100], x10: c_h[0..100], x11: l_c[50...300], x12: r_rotor_outer[0..30]
    % x13: m_w[0..100], x14: m_th[0..100], x15: l_m[0..200], x16: J_rated[0..5], x17: use_35H440_in_teeth[0..1]
    % x18: use_35H440_in_rotor[0..1], x19: slot_number[3..12], x20: num_pole[2..12]

    result = zeros(1, length(x)); % 결과값 초기화

    while true
        % 랜덤 값 생성
        fprintf('Generating random values...\n'); % 디버깅용 출력
        depth = x(1, 1) + (x(1, 2) - x(1, 1)) * rand(); % depth
        r_so = x(2, 1) + (x(2, 2) - x(2, 1)) * rand(); % r_so
        r_si = x(3, 1) + (x(3, 2) - x(3, 1)) * rand(); % r_si
        th_core = x(4, 1) + (x(4, 2) - x(4, 1)) * rand(); % th_core
        w_teeth = x(5, 1) + (x(5, 2) - x(5, 1)) * rand(); % w_teeth
        slot_ratio = x(6, 1) + (x(6, 2) - x(6, 1)) * rand(); % slot_ratio
        shoe_1 = x(7, 1) + (x(7, 2) - x(7, 1)) * rand(); % shoe_1
        shoe_2 = x(8, 1) + (x(8, 2) - x(8, 1)) * rand(); % shoe_2
        c_w = x(9, 1) + (x(9, 2) - x(9, 1)) * rand(); % c_w
        c_h = x(10, 1) + (x(10, 2) - x(10, 1)) * rand(); % c_h
        l_c = x(11, 1) + (x(11, 2) - x(11, 1)) * rand(); % l_c
        r_rotor_outer = x(12, 1) + (x(12, 2) - x(12, 1)) * rand(); % r_rotor_outer
        m_w = x(13, 1) + (x(13, 2) - x(13, 1)) * rand(); % m_w
        m_th = x(14, 1) + (x(14, 2) - x(14, 1)) * rand(); % m_th
        l_m = x(15, 1) + (x(15, 2) - x(15, 1)) * rand(); % l_m
        J_rated = x(16, 1) + (x(16, 2) - x(16, 1)) * rand(); % J_rated
        use_35H440_in_teeth = round(x(17, 1) + (x(17, 2) - x(17, 1)) * rand()); % use_35H440_in_teeth
        use_35H440_in_rotor = round(x(18, 1) + (x(18, 2) - x(18, 1)) * rand()); % use_35H440_in_rotor
        slot_number = round(x(19, 1) + (x(19, 2) - x(19, 1)) * rand()); % slot_number
        num_pole = round(x(20, 1) + (x(20, 2) - x(20, 1)) * rand()); % num_pole

        % 유효성 검사
        if (r_so < l_c) || (l_c < r_si) || (r_so < r_si) % 외경&코일위치&내경 간섭함
            continue; % 유효하지 않음
        
        elseif (l_m < m_th / 2) % 자석 겹침
            continue; % 유효하지 않음

        elseif (sqrt((l_c + (c_h/2))^2 + ((w_teeth/2) + c_w)^2) > (r_so - th_core)) % 외경&코일 간섭함
            continue; % 유효하지 않음

        elseif (sqrt((w_teeth/2)^2 + (l_c - c_h/2)^2)) > (r_si + shoe_1 + shoe_2) % 코일&슬롯 간섭함
            continue; % 유효하지 않음
        
        elseif (atan(((w_teeth/2) + c_w) / (l_c - (c_h/2))) > pi/slot_number) % 코일끼리 간섭함
            continue; % 유효하지 않음
        
        elseif (sqrt((l_m + (m_th/2))^2 + (m_w/2)^2)) > r_rotor_outer % 로터%자석 간섭함
            continue; % 유효하지 않음

        elseif (atan((m_w/2) / (l_m - m_th/2)) > (pi/num_pole)) % 자석끼리 간섭함
            continue; % 유효하지 않음
        end

        % 유효한 입력 생성
        result = [depth, r_so, r_si, th_core, w_teeth, slot_ratio, shoe_1, shoe_2, c_w, c_h, l_c, r_rotor_outer, m_w, m_th, l_m, J_rated, use_35H440_in_teeth, use_35H440_in_rotor, slot_number, num_pole];
        break;
    end
end