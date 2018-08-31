function DMP_object = digit3(layout, DMP, visualize)

  %% Digit parameters
  s_fi1=10*pi/180;
  s_r1=0.1;
  s_r2=0.1;
  s_fis=10*pi/180;
  s_dfi=20*pi/180;

  fis1=160*pi/180+rand_number()*s_fis;
  dfi1=250*pi/180+rand_number()*s_dfi;
  r1x=layout.w/2+rand_number()*s_r1;
  r1y=layout.w/2+rand_number()*s_r1;

  fis2=90*pi/180+rand_number()*s_fis;
  dfi2=250*pi/180+rand_number()*s_r1;
  r2x=layout.w/2+rand_number()*s_r2;
  r2y=layout.w/2+rand_number()*s_r2;

  fi1=-120*pi/180+rand_number()*s_fi1;

  %% Draw digit 
  n=1;
  A(n,1:2)=[0 0];
  n=n+1;
  fis=fis1;
  rx=r1x;
  ry=r1y;
  yc=-rx*sin(fis);
  xc=-ry*cos(fis);

  dfi=dfi1;
  d=8;
  for i=1:d;
  A(n,1:2)=[A(n-i,1)+xc+rx*cos(fis-dfi*i/d) A(n-i,2)+yc+ry*sin(fis-dfi*i/d)];
  n=n+1;
  end

  rx=r2x;
  ry=r2y;
  fis=fis2;
  yc=-ry*sin(fis);
  xc=-rx*cos(fis);

  dfi=dfi2;
  d=8;
  for i=1:d;
  A(n,1:2)=[A(n-i,1)+xc+rx*cos(fis-dfi*i/d) A(n-i,2)+yc+ry*sin(fis-dfi*i/d)];
  n=n+1;
  end
  n=n-1;

  % Center digit
  x_max=max(A(:,1));
  x_min=min(A(:,1));
  y_max=max(A(:,2));
  y_min=min(A(:,2));

  A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);

  % DMP Calculation
  [ DMP_object] = generatedmptraj(A,DMP,visualize);