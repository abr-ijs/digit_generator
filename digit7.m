function DMP_object = digit7(layout, DMP, visualize)

  %% Digit parameters
  s_l1=0.1;
  s_l2=0.2;
  s_fi2=5*pi/180;
  s_fi1=10*pi/180;

  l1=layout.w+rand_number()*s_l1;

  fi2=-90*pi/180-atan(layout.w/layout.h)+rand_number()*s_fi2;
  fi1=(0)*pi/180+rand_number()*s_fi1;
  l2=layout.h/abs(sin(fi2))+rand_number()*s_l2;

  %% Draw digit
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

  %% Center digit
  x_max=max(A(:,1));
  x_min=min(A(:,1));
  y_max=max(A(:,2));
  y_min=min(A(:,2));

  A=A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);

  [ DMP_object] = generatedmptraj(A,DMP,visualize);