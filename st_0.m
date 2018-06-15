function DMP_object=st_0(postavitev,DMP,ploting)

%% Parametri stevke

% Sigma
s_r1 = 0.2; % Radij elipse
s_r2 = 0.1; % Radij elipse

% Center
xCenter = 0;
yCenter = 0;

% Dolocanje polmerov elipse
xRadius = postavitev.w/2+rand_number()*s_r1;
yRadius = postavitev.h/2+rand_number()*s_r2;


%% Izris crke s tockami

d=16; % Stevilo tock po krogu

theta = 0 : (2*pi/d) : 2*pi;

A(:,1) = xRadius * cos(theta) + xCenter;
A(:,2) = yRadius * sin(theta) + yCenter;




% Izracun DMP
[ DMP_object]=st_2del(A,DMP,ploting); 