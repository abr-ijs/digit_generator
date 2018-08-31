function DMP_object = digit4(layout, DMP, visualize)

  %% Digit parameters
  % Sigma
  s_l1=0.1;
  s_l2=0.1;
  s_l3=0.3;
  s_fi1=5*pi/180;
  s_fi2=3*pi/180;
  s_fi3=3*pi/180;

  l1=layout.w+rand_number()*s_l1;  % horizontal line
  fi1=(180)*pi/180+rand_number()*s_fi1; % as horizontal lines

  % dolzina in kot posevnine
  fi2=atan(layout.h/layout.w)+rand_number()*s_fi2;
  l2=(2/3)*layout.h/abs(sin(fi2))+rand_number()*s_l2;

  % dolzina in kot vertikale
  fi3=(-90)*pi/180+rand_number()*s_fi3;
  l3=layout.h+rand_number()*s_l3;

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
  n=n+1;
  A(n,1:2)=[A(n-1,1)+(l3/2)*cos(fi3) A(n-1,2)+(l3/2)*sin(fi3)];
  n=n+1;
  A(n,1:2)=[A(n-1,1)+(l3/2)*cos(fi3) A(n-1,2)+(l3/2)*sin(fi3)];

  % Center digit
  x_max=max(A(:,1));
  x_min=min(A(:,1));
  y_max=max(A(:,2));
  y_min=min(A(:,2));

  A = A-repmat([mean([x_max x_min]) mean([y_max y_min])],[n,1]);

  % DMP Calculation
  [ DMP_object] = generatedmptraj(A,DMP,visualize);