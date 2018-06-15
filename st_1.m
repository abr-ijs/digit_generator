function DMP_object=st_1(postavitev,DMP,ploting)

%% Parametri èrke

%Sigma
s_l1 = 0.1;
s_l2 = 0.3;
s_fi2 = 5*pi/180;
s_fi1 = 10*pi/180;


l2 = postavitev.h + rand_number()*s_l2;     %% dolzina stebla
l1 = postavitev.h/2 + rand_number()*s_l1;   %% dolzina veje
fi2 = -90*pi/180 + rand_number()*s_fi2;     %% kot stebla
fi1 = (58)*pi/180 + rand_number()*s_fi1;    %% kot med vejo in steblom


%% Izris èrke z toèkami
clear A
n=1;
A(n,1:2)=[0 0];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi1) A(n-1,2)+(l1/2)*sin(fi1)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi1) A(n-1,2)+(l1/2)*sin(fi1)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l2/2)*cos(fi2) A(n-1,2)+(l2/2)*sin(fi2)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l2/2)*cos(fi2) A(n-1,2)+(l2/2)*sin(fi2)];

% Centriranje crke
x_max=max(A(:,1));
x_min=min(A(:,1));
y_max=max(A(:,2));
y_min=min(A(:,2));

A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);

% Izracun DMP
DMP_object=st_2del(A,DMP,ploting);

