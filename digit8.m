function DMP_object = digit8(layout, DMP, visualize)

  %% Digit parameters
  % fis1=-90*pi/180;
  % dfi1=-360*pi/180;
  % r1=layout.w/2;
  % fis2=90*pi/180;
  % dfi2=360*pi/180;
  % r2=layout.w/2;
  % +rand_number()*s_r1
  % +rand_number()*s_r2
  s_ry=0.1;
  s_rx=0.1;

  xRadius1 = layout.w/2+rand_number()*s_rx;
  yRadius1 = layout.h/4+rand_number()*s_ry;
  xRadius2 = layout.w/2+rand_number()*s_rx;
  yRadius2 = layout.h/4+rand_number()*s_ry;

  xCenter1 = 0.1*rand_number();
  yCenter1 = yRadius1;
  xCenter2 = 0.1*rand_number();
  yCenter2 = -yRadius2;

  %% Draw digit
  % clear A
  % n=1;
  % A(n,1:2)=[0 0];
  % n=n+1;
  % yc=1;
  % xc=0;
  % r=r1;
  % fis=fis1;
  % dfi=dfi1;
  % d=16;
  % for i=1:d;
  % A(n,1:2)=[A(n-i,1)+xc+r*cos(fis-dfi*i/d) A(n-i,2)+yc+r*sin(fis-dfi*i/d)];
  % n=n+1;
  % end
  % yc=-1;
  % xc=0;
  % r=r2;
  % fis=fis2;
  % dfi=dfi2;
  % d=16;
  % for i=1:d;
  % A(n,1:2)=[A(n-i,1)+xc+r*cos(fis-dfi*i/d) A(n-i,2)+yc+r*sin(fis-dfi*i/d)];
  % n=n+1;
  % end
  % n=n-1;
  % 
  % x_max=max(A(:,1));
  % x_min=min(A(:,1));
  % y_max=max(A(:,2));
  % y_min=min(A(:,2));
  % 
  % 
  % A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);


  d=16;
  theta = -pi/2 : (2*pi/d) : 3*pi/2;
  A(:,1) = xRadius1 * cos(theta) + xCenter1;
  A(:,2) = yRadius1 * sin(theta) + yCenter1;

  d=16;
  theta = pi/2 : -(2*pi/d) : -3*pi/2;
  A1(:,1)=xRadius2 * cos(theta) + xCenter2;
  A1(:,2)= yRadius2 * sin(theta) + yCenter2;
  A=[A;A1];

  [ DMP_object] = generatedmptraj(A,DMP,visualize);