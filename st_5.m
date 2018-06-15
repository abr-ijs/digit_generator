function DMP_object=st_5(postavitev,DMP,ploting)

%% Parametri èrke


s_l1=0.1;
s_l2=0.1;
s_l3=0.1;
s_fi2=5*pi/180;
s_fi3=5*pi/180;
s_fi1=10*pi/180;
s_r1=0.1;
s_fis=10*pi/180;

s_dfi=12*pi/180;


l1=postavitev.w+rand_number()*s_l1;
r1x=postavitev.w/2+rand_number()*s_r1;
r1y=postavitev.w/2+rand_number()*s_r1;
l2=postavitev.h-2*r1y+rand_number()*s_l2 ;
l3=r1x+rand_number()*s_l1;

fi1=(-180)*pi/180+rand_number()*s_fi1;
fi2=(-90)*pi/180+rand_number()*s_fi2;
fi3=(-0)*pi/180+rand_number()*s_fi3;

fis1=90*pi/180;
dfi1=240*pi/180+rand_number()*s_dfi;






%% Izris èrke z toèkami



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
n=n+1;
A(n,1:2)=[A(n-1,1)+(l3/2)*cos(fi3) A(n-1,2)+(l3/2)*sin(fi3)];
n=n+1;
A(n,1:2)=[A(n-1,1)+(l3/2)*cos(fi3) A(n-1,2)+(l3/2)*sin(fi3)];
n=n+1;

fis=fis1;
rx=r1x;
ry=r1y;
yc=-ry*sin(fis);
xc=-rx*cos(fis);

dfi=dfi1;
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