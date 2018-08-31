function DMP_object = digit0(layout, DMP, visualize)

  %% Digit parameters
  % Sigma
  s_r1 = 0.2; % Ellipse radius
  s_r2 = 0.1; % Ellipse radius

  % Center
  xCenter = 0;
  yCenter = 0;

  % Determining the ellipse radius
  xRadius = layout.w/2+rand_number()*s_r1;
  yRadius = layout.h/2+rand_number()*s_r2;

  %% Draw letters with dots
  d=16; % Number of points per circle

  theta = 0 : (2*pi/d) : 2*pi;

  A(:,1) = xRadius * cos(theta) + xCenter;
  A(:,2) = yRadius * sin(theta) + yCenter;
  
  % DMP calculation
  [ DMP_object] = generatedmptraj(A, DMP, visualize); 