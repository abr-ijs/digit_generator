function [DMP_param] = DMP_reconstruct_adapted(y, yd, ydd, time, DMP_param)
% DMP_estimate   Calculate discrete DMP parameters from training data
%
% INPUT measured values      
%   y:    ... positions(time)
%   yd:   ... velocities(time)
%   ydd:  ... accelerations(time)
%   time: ... sample times
%   DMP_param: ... constants for differential equations (N, alpha_x, alpha_z, beta_z)   
%
% OUTPUT learned values stored in DMP_param: 
%   w          ... weight vector of size(Nx1)
%   c, sigma2: ... centers of Gaussian kernels
%   tau:       ... time scales
%   goal:      ... final position

% Copyright (C) Ales Ude, Andrej Gams

for h=1:size(y,2)
%% parameters
epsilon = 1.0e-8; % Cutoff constant for Gaussian kernels
tau = time(end);  % Timing
goal  = y(end,h);   % The goal

%% Copy DMP parameters
N = DMP_param.N;
alpha_x = DMP_param.a_x;
alpha_z = DMP_param.a_z;
beta_z = DMP_param.a_z/4;

%% Initial parameters for target trajectory and fitting
%% Gausian kernel functions
c_lin = linspace(0, 1, N);
c = exp(-alpha_x * c_lin);
%% Kernel width
sigma2 = (diff(c)*0.5).^2;
sigma2 = [sigma2, sigma2(end)];

% Differential equation values for fitting
ft = tau^2*ydd(:,h) - alpha_z * (beta_z * (goal - y(:,h)) - tau * yd(:,h));

% Time replacement parameter
x = exp(-alpha_x/tau * time);

A = [];
for i = 1:length(time)
  psi = exp(-0.5*(((x(i) - c).^2./sigma2)));
  fac = x(i) / sum(psi);
  psi = fac * psi;

  idx = (psi < epsilon);
  psi(idx) = 0;

  A = [A; psi];
end

w = A \ ft;

DMP_param.c = c;
DMP_param.sigma2 = sigma2;
DMP_param.w(:,h) = w;
DMP_param.tau = tau;
DMP_param.goal(h) = goal;
DMP_param.y0=y(1,:);
end
end