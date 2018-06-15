function DMP_object =st_2(postavitev,DMP,ploting)

%% Parametri èrke

% Sigma
s_l1=0.1;
s_l2=0.3;
s_fi2=5*pi/180;
s_fi1=5*pi/180;
s_r1=0.1;
s_fis=10*pi/180;

% polmera elipse krivulje
r1x=postavitev.w/2+rand_number()*s_r1;
r1y=postavitev.w/2+rand_number()*s_r1;

% dolzina in kot posevnine
l2=postavitev.w+rand_number()*s_l2;

l1=(postavitev.h-r1y)+rand_number()*s_l1; 
if l1>sqrt((postavitev.h-r1y)^2+r1x^2)
    l1=sqrt((postavitev.h-r1y)^2+r1x^2);
end

fi2=-(3*pi/2-atan((postavitev.h-r1y)/r1x)-asin(l1/(sqrt((postavitev.h-r1y)^2+r1x^2))));%+rand_number()*s_fi2-120*pi/180;

fis1=160*pi/180+rand_number()*s_fis;

dfi1=180*pi/180-(fi2+pi/2)-(pi-fis1);



fi1=(0)*pi/180+rand_number()*s_fi1;



%% Izris crke z toèkami
n=1;
A(n,1:2)=[0 0];
n=n+1;
fis=fis1;
rx=r1x;
ry=r1y;
yc=-ry*sin(fis);
xc=-rx*cos(fis);

%% Izris crke s tockami
dfi=dfi1;
d=9;
for i=1:d;
A(n,1:2)=[A(n-i,1)+xc+rx*cos(fis-dfi*i/d) A(n-i,2)+yc+ry*sin(fis-dfi*i/d)];
n=n+1;
end
A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi2) A(n-1,2)+(l1/2)*sin(fi2)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi2) A(n-1,2)+(l1/2)*sin(fi2)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l2/2)*cos(fi1) A(n-1,2)+(l2/2)*sin(fi1)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l2/2)*cos(fi1) A(n-1,2)+(l2/2)*sin(fi1)];

% Centriranje crke
x_max=max(A(:,1));
x_min=min(A(:,1));
y_max=max(A(:,2));
y_min=min(A(:,2));

A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);
% Izracun DMP
[ DMP_object]=st_2del(A,DMP,ploting);