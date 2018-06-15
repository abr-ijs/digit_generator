function DMP_object=st_9(postavitev,DMP,ploting)

%% Parametri èrke

s_r1=0.1;
s_r2=0.1;
s_fi2=10*pi/180;
s_fi1=10*pi/180;

r1x=postavitev.w/2+rand_number()*s_r1;
r1y=postavitev.w/2+rand_number()*s_r2;
r2x=postavitev.w/2+rand_number()*s_r1;
r2y=postavitev.h/2+rand_number()*s_r2;

l1=postavitev.h-r1y-r2y;

fi1=(-90)*pi/180+rand_number()*s_fi1;


fis1=0*pi/180;
dfi1=360*pi/180;

fis2=0*pi/180;
dfi2=130*pi/180+rand_number()*s_fi2;





%% Izris èrke z toèkami



n=1;
A(n,1:2)=[0 0];
n=n+1;
yc=0;
xc=-r1x;
rx=r1x;
ry=r1y;
fis=fis1;
dfi=dfi1;
d=16;
for i=1:d;
A(n,1:2)=[A(n-i,1)+xc+rx*cos(fis-dfi*i/d) A(n-i,2)+yc+ry*sin(fis-dfi*i/d)];
n=n+1;
end


% 
% A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi1) A(n-1,2)+(l1/2)*sin(fi1)];
% n=n+1;
% A(n,1:2)=[A(n-1,1)+(l1/2)*cos(fi1) A(n-1,2)+(l1/2)*sin(fi1)];
% n=n+1;

yc=-r1y;
xc=-r2x;
rx=r2x;
ry=r2y;
fis=fis2;
dfi=dfi2;
d=9;
for i=1:d;
A(n,1:2)=[A(n-i,1)+xc+rx*cos(fis-dfi*i/d) A(n-i,2)+yc+ry*sin(fis-dfi*i/d)];
n=n+1;
end
n=n-1;

x_max=max(A(:,1));
x_min=min(A(:,1));
y_max=max(A(:,2));
y_min=min(A(:,2));


A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);
[ DMP_object]=st_2del(A,DMP,ploting);