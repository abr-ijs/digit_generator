function [t_res, y_res] = DMP_track_adapted(DMP_param, y0_in, dt, euler)
% DMP_track      Integrate a discrete dynamic movement primitive
%

% SPREMENJENA!!!!!!!!!!!!!!


% INPUT     
%   DMP_param:   ... parameters specifying a periodic DMP
%   y0:          ... initial values for integration
%   times:       ... time step
%   euler:       ... type of integration
%
% OUTPUT 
%   t_res:       ... integration times
%   y_res:       ... integrated positions and velocities

% Copyright (C) Ales Ude, Andrej Gams

if ~exist('euler');
  euler = false;
end

M = int32(DMP_param.tau/dt);

tau = DMP_param.tau;

Y = zeros(M+2,size(DMP_param.w,2));
Yd = zeros(M+1,size(DMP_param.w,2));
Ydd = zeros(M+1,size(DMP_param.w,2));
  
for dimen=1:size(DMP_param.w,2)
    
y0=y0_in(dimen);

if ~euler

  OPTIONS.RelTol = 1.0e-12;    
  if numel(y0) == 1
    y0 = [y0(1); 0];
  else
    y0 = [y0(1); y0(2)*tau];
  end
  if exist('OCTAVE_VERSION', 'builtin') ~= 0
    [t_res, y_res] = ode45(@differential_equation, linspace(0, tau, M+1), ...
                          [1; y0], OPTIONS, DMP_param, dimen);
  else
    [t_res, y_res] = ode113(@differential_equation, linspace(0, tau, M+1), ...
                            [1; y0], OPTIONS, DMP_param, dimen);
  end
  %y_res = [y_res(:,2), y_res(:,3) / tau];

  Y_ode(:,dimen) = y_res(:,2);
  Yd(:,dimen) = y_res(:,3) / tau;
else
  %% Euler integration

  %% init params for target traj. and fitting
  x = 1;
  if numel(y0) == 2
    z = y0(2)*tau;
  else
    z = 0;
  end
  y = y0;
  t = 0;

  %Y = [];
 
  Y(1,dimen) = y;
  Yd(1,dimen) = z;

  for i = 0:M
    %% % the weighted sum of the locally weighted regression models
    psi = exp(-0.5*(x-DMP_param.c).^2./DMP_param.sigma2)';
    % fx = sum((DMP_param.w*x).*psi) / sum(psi) * (DMP_param.goal - y00);
    fx = sum((DMP_param.w(:,dimen)*x).*psi) / sum(psi);
  
    %% derivatives
    dx = -DMP_param.a_x * x;
    dz = DMP_param.a_z * (DMP_param.a_z/4 * (DMP_param.goal(dimen) - y) - z) + fx;
    dy = z;

    %% temporal scaling
    dx = dx / DMP_param.tau;
    dz = dz / DMP_param.tau;
    dy = dy / DMP_param.tau;
  
    %% Euler integration
    x = x + dx*dt;
    z = z + dz*dt;
    y = y + dy*dt;

    % Y = [Y; y + y0];
    Y(i+2,dimen) = y;
    Yd(i+1,dimen) = dy;
    Ydd(i+1,dimen) = dz / DMP_param.tau;
  end

end

end  

if ~euler
    
     y_res = [Y_ode, Yd, Ydd];
else
  Y = Y(1:end-1,:);
  y_res = [Y, Yd, Ydd];
  t_res = linspace(0, tau, M+1)';
  
end
end

% Differential equation definition for DMPs

function [f] = differential_equation(t, y, DMP_param,dimen)

f(1,1) = -DMP_param.a_x / DMP_param.tau * y(1);
f(2,1) = y(3) / DMP_param.tau;

psi = exp(-0.5*(y(1) - DMP_param.c).^2 ./ DMP_param.sigma2)';
fx = sum((DMP_param.w(:,dimen)*y(1)).*psi) / sum(psi);
f(3,1) = (DMP_param.a_z * ((DMP_param.a_z/4) * (DMP_param.goal(dimen) - y(2)) - ...
                               y(3)) + fx) / DMP_param.tau;
end