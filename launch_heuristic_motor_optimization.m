function launch_heuristic_motor_optimization()
    % 모터 최적화를 실행합니다.

    % x1: depth[0..200], x2: r_so[0..300], x3: r_si[0..300],x4: th_core[0..10], x5: w_teeth[0..150], x6: slot_ratio[0..1]
    % x7: shoe_1[0..100], x8: shoe_2[0..100], x9: c_w[0..100], x10: c_h[0..100], x11: l_c[50...300], x12: r_rotor_outer[0..30]
    % x13: m_w[0..100], x14: m_th[0..100], x15: l_m[0..200], x16: J_rated[0..5], x17: use_35H440_in_teeth[0..1]
    % x18: use_35H440_in_rotor[0..1], x19: slot_number/3[1..4], x20: num_pole/2[1..12]
    
    depth_min = 200; depth_max = 200;
    r_so_min = 300; r_so_max = 300;
    r_si_min = 100; r_si_max = 300;
    th_core_min = 1; th_core_max = 30;
    w_teeth_min = 20; w_teeth_max = 100;
    slot_ratio_min = 0; slot_ratio_max = 1;
    shoe_1_min = 1; shoe_1_max = 100;
    shoe_2_min = 1; shoe_2_max = 100;
    c_w_min = 20; c_w_max = 100;
    c_h_min = 20; c_h_max = 100;
    l_c_min = 100; l_c_max = 300;
    r_rotor_outer_min = 50; r_rotor_outer_max = 300;
    m_w_min = 30; m_w_max = 100;
    m_th_min = 20; m_th_max = 100;
    l_m_min = 20; l_m_max = 300;
    J_rated_min = 5; J_rated_max = 5;
    use_35H440_in_teeth_min = 1; use_35H440_in_teeth_max = 1;
    use_35H440_in_rotor_min = 1; use_35H440_in_rotor_max = 1;
    slot_number_min = 1; slot_number_max = 6;
    num_pole_min = 1; num_pole_max = 10;

    x = [depth_min, depth_max; r_so_min, r_so_max; r_si_min, r_si_max; th_core_min, th_core_max; ...
    w_teeth_min, w_teeth_max; slot_ratio_min, slot_ratio_max; shoe_1_min, shoe_1_max; shoe_2_min, shoe_2_max; ...
    c_w_min, c_w_max; c_h_min, c_h_max; l_c_min, l_c_max; r_rotor_outer_min, r_rotor_outer_max; ...
    m_w_min, m_w_max; m_th_min, m_th_max; l_m_min, l_m_max; J_rated_min, J_rated_max; ...
    use_35H440_in_teeth_min, use_35H440_in_teeth_max; use_35H440_in_rotor_min, use_35H440_in_rotor_max; ...
    slot_number_min, slot_number_max; num_pole_min, num_pole_max];

    min_vector = heuristic_optimization(x); % 최적화 함수 호출

    TR = get_TR(min_vector); % 최적화된 벡터를 사용하여 TR 계산

    % 최적화된 모터의 개별 요소는 heuristic_optimization.m에서 출력됨
    fprintf('최적화된 토크: %.2f Nm\n', TR(1)); % 최적화된 토크 출력
    fprintf('최적화된 리플: %.2f %%\n', TR(2)); % 최적화된 리플 출력
end