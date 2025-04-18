function TR = get_TR(x)
    % 입력된 x를 기반으로 모터를 시뮬레이션하고, 토크와 리플을 계산하여 반환하는 함수
    % x: [x1, x2, x3, ...] 형태의 벡터로, 모터의 파라미터를 나타냄
    % x1: depth, x2: r_so, x3: r_si, x4: w_teeth, x5: slot_ratio, x6: shoe_1
    % x7: shoe_2, x8: c_w, x9: c_h, x10: l_c, x11: r_rotor_outer, x12: m_w
    % x13: m_th, x14: l_m, x15: J_rated, x16: use_35HH40_in_teeth


    % [T R]의 형태로 출력
    

    try
        close all;


        openfemm; %FEMM실행
        newdocument(0); %새 Document 창 실행(정자계 해석)

        name_fem='temp.fem'; %파일 이름 설정(필요 없음)
        mi_saveas(name_fem); %파일 저장

        %%%%%%%%%%%%%%%%%%%%%%%%% 변수 설정 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 스테이터 변수
        depth=x(1); %화면방향 깊이
        r_so=x(2); % 스테이터 직경
        r_si=x(3); % 스테이터 내경(슬롯 거리)
        % if r_si >= r_so % r_si는 r_so보다 작아야 함
        %     r_si = r_so - 1;
        %     % fprintf('r_si가 다음으로 설정되었습니다: %f\n', r_si);
        % end

        th_core=x(4); %스테이터 두께
        w_teeth=x(5); % 코일간의 거리
        slot_ratio=x(6); % 슬롯 비율
        shoe_1=x(7); % 슬롯 슈1 크기
        shoe_2=x(8); % 슬롯 슈2 크기

        % 코일 변수
        c_w=x(9); %코일의 너비
        c_h=x(10); %코일의 높이
        l_c=x(11); %중심점(0,0)으로 부터의 코일 위치
        % if l_c - c_h < r_si % 코일의 위치는 r_si보다 바깥에 위치해야 함
        %     l_c = r_si + c_h + 1;
        %     % fprintf('l_c가 다음으로 설정되었습니다: %f\n', l_c);
        % end
        % if l_c + c_h > r_so % 코일의 위치는 r_so보다 안쪽에 위치해야 함
        %     l_c = r_so - c_h - 1;
        %     % fprintf('l_c가 다음으로 설정되었습니다: %f\n', l_c);
        % end

        % % shoe의 합은 l_c - r_si보다 작아야함
        % max_shoe = l_c - r_si;
        % sum = shoe_1 + shoe_2;
        % if sum > max_shoe % shoe의 합이 l_c - r_si보다 크면 안됨
        %     shoe_1 = max(shoe_1 * max_shoe / sum - c_h / 2, 0);
        %     shoe_2 = max(shoe_2 * max_shoe / sum - c_h / 2, 0);
        %     % fprintf('shoe_1과 shoe_2가 다음으로 설정되었습니다: %f, %f\n', shoe_1, shoe_2);
        % end


        % 로터 변수
        r_rotor_outer=x(12); %로터 바깥쪽 반지름
        % if r_rotor_outer >= r_si % r_rotor_outer는 r_si보다 작아야 함
        %  r_rotor_outer = r_si - 1;
        %     % fprintf('r_rotor_outer가 다음으로 설정되었습니다: %f\n', r_rotor_outer);
        % end

        % 자석 변수
        m_w=x(13); %자석의 너비
        m_th=x(14); %자석의 높이
        l_m=x(15); %중심점(0,0)으로부터의 자석 위치
        % if l_m + m_th > r_rotor_outer % 자석의 위치는 r_rotor_outer보다 안쪽에 위치해야 함
        %     l_m = r_rotor_outer - m_th - 1;
        %     % fprintf('l_m가 다음으로 설정되었습니다: %f\n', l_m);
        % end


        % 회전 자계, 전류 밀도 변수
        J_rated=x(16); %코일영역 전류밀도
        use_35HH40_in_teeth=x(17); % teeth에 35H440 자재 사용 여부
        use_35HH40_in_rotor=x(18); % 회전자에 35H440 자재 사용 여부

        slot_number=x(19) * 3; % 슬롯 개수 설정
        num_pole=x(20) * 2; %회전자 자석 개수

        % 변화 없는 변수
        gamma=0; %전류각, SPM은 0도로 고정
        N=12; %0도부터 360까지 몇번에 걸쳐 회전시킬지

        %%%%%%%%%%%%%%%%%%%%%%%%% 파일 저장 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        %재료 불러오기
        mi_getmaterial('N42'); % N42 자석 불러오기
        mi_getmaterial('Air');      % FEMM 내장 공기 물성 불러오기
        mi_getmaterial('M-19 Steel');  % FEMM 내장 철심 재료 불러오기
        mi_modifymaterial('M-19 Steel',0,'35H440');   % 철심 물성 수정

        % 코일 재료 정의 (전류 밀도는 나중에 수정)
        mi_addmaterial('a+', 1, 1, 0, 0, 56)
        mi_addmaterial('a-', 1, 1, 0, 0, 56)
        mi_addmaterial('b+', 1, 1, 0, 0, 56)
        mi_addmaterial('b-', 1, 1, 0, 0, 56)
        mi_addmaterial('c+', 1, 1, 0, 0, 56)
        mi_addmaterial('c-', 1, 1, 0, 0, 56)

        mi_addboundprop('A_0',0,0,0,0);	%도화지의 태두리 기본 설정

        %%%%%%%%%%%%%%%%%%%%%%%%   도화지 설정   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        mi_probdef(0,'millimeters','planar',1e-009,depth,30); % 문제 단위와 형상 설정

        square=1000;    % FEMM 도화지 크기
        drawrectangle(-square/2,-square/2,square/2,square/2);
        mi_selectrectangle(-square/2,-square/2,square/2,square/2,4);

        mi_setsegmentprop('A_0',0, 1,0,100); %바운다리 컨디션 설정
        add_label(0,square/2-1,'Air',0,11); %도화지 물성치 설정

        mi_clearselected();
        mi_zoomnatural();

        %%%%%%%%%%%%%%%%%%%%%%%%  스테이터 그리기  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % 스테이터 외부 원 그리기
        x1=0;y1=0;

        mi_addnode(x1+r_so,y1);
        mi_addnode(x1-r_so,y1);
        mi_addarc(x1+r_so,y1,x1-r_so,y1,180,5);
        mi_addarc(x1-r_so,y1,x1+r_so,y1,180,5);

        mi_selectarcsegment(0,r_so);
        mi_selectarcsegment(0,-r_so);
        mi_setarcsegmentprop(1,'A_0',0, 0);
        mi_clearselected();
        mi_zoomnatural();


        %%%%%%%%%%%%%%%%%%%%%%%%%% 코일부 그리기 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %'+' coil 그리기
        drawrectangle(-w_teeth/2-c_w,l_c-c_h/2,-w_teeth/2,l_c+c_h/2); 


        % 슬롯과 슬롯 사이의 물성치
        coil_center_x = -w_teeth/2-c_w-0.1;  % 생선된 코일 바로 옆
        coil_center_y = (l_c-c_h/2 + l_c+c_h/2)/2;
        add_label(coil_center_x, coil_center_y, 'Air', 0, 12); % air

        %%%%%%%%%%%%%%%%%%%%%%%%%% 스테이터 그리기 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 슬롯 형상 좌표 설정 및 좌표 선 연결
        mi_addnode(-(r_so-th_core)*cos(pi/2-(asin(w_teeth*0.5/(r_so-th_core)))),(r_so-th_core)*sin(pi/2-(asin(w_teeth*0.5/(r_so-th_core)))));
        mi_addnode(0,r_si);
        mi_addnode(r_si*cos((pi/2+pi/slot_number*slot_ratio)),r_si*sin((pi/2+pi/slot_number*slot_ratio)));
        mi_addnode((r_si+shoe_2)*cos((pi/2+pi/slot_number*slot_ratio)),(r_si+shoe_2)*sin((pi/2+pi/slot_number*slot_ratio)));
        mi_addnode(-(r_si+shoe_2+shoe_1)*cos(pi/2-(asin(w_teeth*0.5/(r_si+shoe_2+shoe_1)))),(r_si+shoe_2+shoe_1)*sin(pi/2-(asin(w_teeth*0.5/(r_si+shoe_2+shoe_1)))));

        mi_addsegment(-(r_so-th_core)*cos((pi/2-(asin(w_teeth*0.5/(r_so-th_core))))),(r_so-th_core)*sin((pi/2-(asin(w_teeth*0.5/(r_so-th_core))))), ...
            -(r_si+shoe_2+shoe_1)*cos((pi/2-(asin(w_teeth*0.5/(r_si+shoe_2+shoe_1))))),(r_si+shoe_2+shoe_1)*sin((pi/2-(asin(w_teeth*0.5/(r_si+shoe_2+shoe_1))))));
        mi_addsegment(-(r_si+shoe_2+shoe_1)*cos((pi/2-(asin(w_teeth*0.5/(r_si+shoe_2+shoe_1))))),(r_si+shoe_2+shoe_1)*sin((pi/2-(asin(w_teeth*0.5/ ...
            (r_si+shoe_2+shoe_1))))),(r_si+shoe_2)*cos((pi/2+pi/slot_number*slot_ratio)),(r_si+shoe_2)*sin((pi/2+pi/slot_number*slot_ratio)));
        mi_addsegment((r_si+shoe_2)*cos((pi/2+pi/slot_number*slot_ratio)),(r_si+shoe_2)*sin((pi/2+pi/slot_number*slot_ratio)),r_si* ...
            cos((pi/2+pi/slot_number*slot_ratio)),r_si*sin((pi/2+pi/slot_number*slot_ratio)));
        mi_addarc(0,r_si,r_si*cos((pi/2+pi/slot_number*slot_ratio)),r_si*sin((pi/2+pi/slot_number*slot_ratio)),180/pi*(pi/slot_number*slot_ratio),5);
        mi_addnode((r_so-th_core)*cos((pi/2+pi/slot_number)),(r_so-th_core)*sin((pi/2+pi/slot_number)));
        mi_addnode((r_si+shoe_2)*cos((pi/2+pi/slot_number)),(r_si+shoe_2)*sin((pi/2+pi/slot_number)));
        mi_addsegment((r_so-th_core)*cos((pi/2+pi/slot_number)),(r_so-th_core)*sin((pi/2+pi/slot_number)),(r_si+shoe_2)*cos((pi/2+pi/slot_number)), ...
            (r_si+shoe_2)*sin((pi/2+pi/slot_number)));
        mi_addsegment((r_si+shoe_2)*cos((pi/2+pi/slot_number)),(r_si+shoe_2)*sin((pi/2+pi/slot_number)),(r_si+shoe_2)*cos((pi/2+pi/slot_number*slot_ratio)), ...
            (r_si+shoe_2)*sin((pi/2+pi/slot_number*slot_ratio)));
        mi_addarc(-(r_so-th_core)*cos((pi/2-(asin(w_teeth*0.5/(r_so-th_core))))),(r_so-th_core)*sin((pi/2-(asin(w_teeth*0.5/(r_so-th_core))))),(r_so-th_core)* ...
            cos((pi/2+pi/slot_number)),(r_so-th_core)*sin((pi/2+pi/slot_number)),180/pi*(pi/slot_number-(asin(w_teeth*0.5/(r_so-th_core)))),5);

        % 코일 및스테이터 형상 회전 복사
        mi_selectcircle(0,0,r_so*2.1,4);
        mi_mirror2(0,0,0,10,4);
        mi_selectcircle(0,0,r_so-1,4);
        mi_copyrotate2(0,0,360/slot_number,slot_number,4);

        if use_35HH40_in_teeth >= 0.5 % 35H440을 teeth에 삽입
            add_label(0, r_so-0.1, '35H440', 0, 11); % 스테이터 내부 공기 물성
        else
            add_label(0, r_so-0.1, 'Air', 0, 11); % 스테이터 내부 공기 물성
        end

        %%%%%%%%%%%%%%%%%%%%%%%로터(회전자) 그리기%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % 로터 그리기
        drawcircle(0,0,r_rotor_outer); 

        % 자석 그리기
        drawrectangle(-m_w/2,l_m-m_th/2,m_w/2,l_m+m_th/2); %자석 그리기
        mi_selectrectangle(-m_w/2,l_m-m_th/2,m_w/2,l_m+m_th/2,4); %자석 선택
        mi_copyrotate2(0,0,360/num_pole,num_pole,4); %처음 그린 자석을 (0,0) 원점 기준으로 360/num_pole 각도로 num_pole 개수만큼 카피

        % %자석 물성치 설정
        for i=1:num_pole
            pole_y = l_m*cos((2*pi/num_pole)*(i-1)); % 자석의 x좌표
            pole_x = l_m*sin((2*pi/num_pole)*(i-1)); % 자석의 y좌표
            if (mod(i,2)==1)
                add_label(pole_x, pole_y,'N42',rad2deg(-(2*pi/num_pole)*(i-1))+90,10); %자석 물성치, 자화방향 설정
            else
                add_label(pole_x, pole_y,'N42',rad2deg(-(2*pi/num_pole)*(i-1))-90,10); %자석 물성치, 자화방향 설정
            end
        end
        % add_label(0,-l_m,'N42',-90,10); %자석 물성치, 자화방향 설정
        % add_label(l_m,0,'N42',-180,10); %자석 물성치, 자화방향 설정
        % add_label(-l_m,0,'N42',0,10); %자석 물성치, 자화방향 설정

        if use_35HH40_in_rotor >= 0.5 % 35H440을 rotor에 삽입
            add_label(0,0,'35H440',0,10); %로터(회전자) 물성치 설정
        else
            add_label(0,0,'Air',0,10); %로터(회전자) 물성치 설정
        end
        add_label(0, r_rotor_outer+0.1, 'Air', 0, 12); % 로터와 슬롯 사이의 물성치

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 코일 물성치 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %코일 개수가 많으면 for 문 사용
        coil_angle=atan((w_teeth/2+c_w/2)/l_c); % 중심 기준 각도
        coil_r=sqrt((w_teeth/2+c_w/2)^2+l_c^2); % 중심까지 반경
        slot_angle=pi*2/slot_number; % 슬롯 각도

        for i=1:slot_number
            if mod(i, 3)==1
                add_label(coil_r*cos(pi/2+coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2+coil_angle+(slot_angle*(i-1))),'a+',0,20); %Coil 물성치
                add_label(coil_r*cos(pi/2-coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2-coil_angle+(slot_angle*(i-1))),'a-',0,20); %Coil 물성치
            elseif mod(i, 3)==2
                add_label(coil_r*cos(pi/2+coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2+coil_angle+(slot_angle*(i-1))),'b+',0,20); %Coil 물성치
                add_label(coil_r*cos(pi/2-coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2-coil_angle+(slot_angle*(i-1))),'b-',0,20); %Coil 물성치
            else
                add_label(coil_r*cos(pi/2+coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2+coil_angle+(slot_angle*(i-1))),'c+',0,20); %Coil 물성치
                add_label(coil_r*cos(pi/2-coil_angle+(slot_angle*(i-1))),coil_r*sin(pi/2-coil_angle+(slot_angle*(i-1))),'c-',0,20); %Coil 물성치
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%% 회전자계 만드는 함수 %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        T_list = []; %토크 결과 저장
        for kk=1:N

            Jd=-J_rated*sin(gamma); %d축 전류밀도
            Jq=J_rated*cos(gamma); %q축 전류밀도
            J=(Jq^2+Jd^2)^0.5; %전류밀도
            theta_d_offset=atan2(Jq,Jd); %전류각

            theta_mech_inc=2*pi/N/(num_pole/2); %로터의 최소 움직임 기계각
            theta_mecha(kk)=theta_mech_inc*(kk-1); %로터의 기계각
            theta_elec(kk)=theta_mecha(kk)*(num_pole/2); %로터의 전기각
            J_a(kk)=J*cos(theta_d_offset+theta_elec(kk)); %'a' phase 전류밀도
            J_b(kk)=J*cos(theta_d_offset-2*pi/3+theta_elec(kk)); %'b' phase 전류밀도
            J_c(kk)=J*cos(theta_d_offset+2*pi/3+theta_elec(kk)); %'c' phase 전류밀도

            mi_modifymaterial('b+',4,J_b(kk)) %FEA 전류밀도 설정
            mi_modifymaterial('b-',4,-J_b(kk)) %FEA 전류밀도 설정
            mi_modifymaterial('a+',4,J_a(kk)) %FEA 전류밀도 설정
            mi_modifymaterial('a-',4,-J_a(kk)) %FEA 전류밀도 설정
            mi_modifymaterial('c+',4,J_c(kk)) %FEA 전류밀도 설정
            mi_modifymaterial('c-',4,-J_c(kk)) %FEA 전류밀도 설정

            mi_analyze(1); %해석 실행
            mi_loadsolution(); %해석 결과 불러오기

            mo_groupselectblock(10); %로터 선택

            T(kk) = mo_blockintegral(22); %로터 토크 불러오기
            T_list = [T_list; T(kk)]; %토크 결과 저장

            mo_close; %해석 결과 닫기, 설정창으로 복귀

            mi_clearselected(); %클리어
            mi_selectcircle(0,0,(r_rotor_outer+1),4); %로터 선택
            mi_selectgroup(10); %로터 물성치 선택
            mi_moverotate(0,0,theta_mech_inc*180/pi); %로터랑 로터 물성치 회전

        end

        mean_T=mean(T_list); %로터 토크 평균값
        R=100*(max(T_list)-min(T_list))/mean_T; %리플 계산

        TR=[mean_T, R]; % [T R] 형태로 출력

        %plot for debug
        % figure(1);
        % plot(T_list,'r-','LineWidth',2); %토크 그래프
    
    catch exception
        fprintf('Error: %s\n', exception.message);
        TR=[-999999, 999999]; % 모터 시뮬레이션 실패 시 [-999999, 999999] 반환
    end
end