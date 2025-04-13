%에너지변환공학_HW5_강예구_ver1
%모터 최적 설계

clear all; clc; close all;

% addpath('C:\femm42\mfiles')  % FEMM의 m파일 경로 추가

openfemm; %FEMM실행
newdocument(0);             %새 Document 창 실행(정자계 해석)

path='C:\Users\lupi1\Documents\살려주세요\에변공\HW5\';          %Path 설정
name_fem='motor_example.fem';   %파일 이름 설정
mi_saveas([path,name_fem]); %파일 저장

%%%%%%%%%%%%%%%%%%%%%%%%% 변수 설정 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 스테이터 변수
depth=100;  %화면방향 깊이 = 자석의 깊이 100mm
slot_number= 3; % 슬롯 개수 설정
r_so=100;   % 스테이터 직경 100
r_si=60; % r_so - r_rotor_outer > r_si

th_core=2; %스테이터 두께
w_teeth=20; % 코일간의 거리
slot_ratio=0.25; % 슬롯 비율
shoe_1=10; % 슬롯 슈1 크기
shoe_2=10; % 슬롯 슈2 크기

% 코일 변수
c_w=10; %코일의 너비
c_h=10; %코일의 높이
l_c=85; %중심점(0,0)으로 부터의 코일 위치

% 로터 변수
r_rotor_outer=55; %로터 바깥쪽 반지름

% 자석 변수
num_pole=4;       %회전자 자석 개수
m_w=30;           %자석의 너비
m_th=10;           %자석의 높이
l_m=40;           %중심점(0,0)으로부터의 자석 위치


% 회전 자계, 전류 밀도 변수
gamma=0; %전류각, SPM은 0도로 고정
N=36; %0도부터 360까지 몇번에 걸쳐 회전시킬지
J_rated=linspace(0, 5, 10); %코일영역 전류밀도를 0부터 5까지 10개로 나누기

T_result=[]; %토크 결과 저장

%%%%%%%%%%%%%%%%%%%%%%%%% 파일 저장 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%재료 불러오기
Hc=900000;                  % 영구자석 보자력 설정
mi_addmaterial('N4X',1.05,1.05,Hc,0,0.56); % 영구자석 물성치 정의
mi_getmaterial('Air');      % FEMM 내장 공기 물성 불러오기
mi_getmaterial('M-19 Steel');  % FEMM 내장 철심 재료 불러오기
mi_modifymaterial('M-19 Steel',0,'35H270');   % 철심 물성 수정

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

for j = J_rated
    %도화지 초기화
    mi_selectcircle(0,0,r_so*2.1,4); %도화지 선택
    mi_deleteselected(); %도화지 삭제
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

    add_label(0, r_so-0.1, 'Air', 0, 11); % 스테이터 내부 공기 물성

    %%%%%%%%%%%%%%%%%%%%%%%로터(회전자) 그리기%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % 로터 그리기
    drawcircle(0,0,r_rotor_outer); 

    % 자석 그리기
    drawrectangle(-m_w/2,l_m-m_th/2,m_w/2,l_m+m_th/2); %자석 그리기
    mi_selectrectangle(-m_w/2,l_m-m_th/2,m_w/2,l_m+m_th/2,4); %자석 선택
    mi_copyrotate2(0,0,360/num_pole,num_pole,4); %처음 그린 자석을 (0,0) 원점 기준으로 360/num_pole 각도로 num_pole 개수만큼 카피

    %자석 물성치 설정
    add_label(0,l_m,'N4X',90,10); %자석 물성치, 자화방향 설정
    add_label(0,-l_m,'N4X',-90,10); %자석 물성치, 자화방향 설정
    add_label(l_m,0,'N4X',-180,10); %자석 물성치, 자화방향 설정
    add_label(-l_m,0,'N4X',0,10); %자석 물성치, 자화방향 설정

    add_label(0,0,'Air',0,10); %로터(회전자) 물성치 설정
    add_label(0, r_rotor_outer+0.1, 'Air', 0, 12); % 로터와 슬롯 사이의 물성치

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 코일 물성치 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %코일 개수가 많으면 for 문 사용
    coil_angle=atan((w_teeth/2+c_w/2)/l_c); % 중심 기준 각도
    coil_r=sqrt((w_teeth/2+c_w/2)^2+l_c^2); % 중심까지 반경
    add_label(coil_r*cos(pi/2+coil_angle),coil_r*sin(pi/2+coil_angle),'a+',0,20); %Coil 물성치
    add_label(coil_r*cos(pi/2-coil_angle),coil_r*sin(pi/2-coil_angle),'a-',0,20); %Coil 물성치
    add_label(coil_r*cos(pi/2+coil_angle-pi*2/3),coil_r*sin(pi/2+coil_angle-pi*2/3),'b+',0,20); %Coil 물성치
    add_label(coil_r*cos(pi/2-coil_angle-pi*2/3),coil_r*sin(pi/2-coil_angle-pi*2/3),'b-',0,20); %Coil 물성치
    add_label(coil_r*cos(pi/2+coil_angle+pi*2/3),coil_r*sin(pi/2+coil_angle+pi*2/3),'c+',0,20); %Coil 물성치
    add_label(coil_r*cos(pi/2-coil_angle+pi*2/3),coil_r*sin(pi/2-coil_angle+pi*2/3),'c-',0,20); %Coil 물성치


    %%%%%%%%%%%%%%%%%%%%%%%%%%% 회전자계 만드는 함수 %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_list=[]; %토크 결과 저장
    for kk=1:N

        Jd=-j*sin(gamma); %d축 전류밀도
        Jq=j*cos(gamma); %q축 전류밀도
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
        T_list=[T_list;T(kk)]; %토크 결과 저장

        mo_close; %해석 결과 닫기, 설정창으로 복귀

        mi_clearselected(); %클리어
        mi_selectcircle(0,0,(r_rotor_outer+1),4); %로터 선택
        mi_selectgroup(10); %로터 물성치 선택
        mi_moverotate(0,0,theta_mech_inc*180/pi); %로터랑 로터 물성치 회전

    end
    T_result=[T_result; mean(T_list)]; %토크 결과 저장
end

figure(1)
% set(gcf,'Position',[100 100 900 400]); % 가로로 긴 창 (가로 900, 세로 400)
plot(J_rated,T_result,'r-','LineWidth',2); % 전류밀도에 따른 토크 그래프
axis auto;
ylabel('Torque[Nm]');
xlabel('J[A/mm^2]');
grid on;
title('Torque-J Characteristics');