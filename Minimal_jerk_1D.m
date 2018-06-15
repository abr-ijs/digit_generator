function [path] = Minimal_jerk_1D(q0,q1,dt,rt)

% Izraèun minimum jerk trajektorij za robotske kote


% INPUT PARAMETERS:
%   q0 - initial robot pose [qa, qb, qc]
%  q1 - final robot pose at release position [qa, qb, qc]
%   dt - time scale
%   qv0 - hitrosti robota ob izpustu
%   rt - èas izpusta
% OUTPUT PARAMETERS
%   path - trajektorija

  


% dq0 = [0 ];
% ddq0 = [1.2] ;
% dq1 = [0 ];
% ddq1 = [-1.2];

dq0 = [0 ];
ddq0 = [0] ;
dq1 = [0 ];
ddq1 = [0];



a543210_qa = polynomial1(q0(1),dq0(1),ddq0(1),q1(1),dq1(1),ddq1(1),rt);



[path_qa, dpath_qa, ddpath_qa] = polynomial2(a543210_qa, dt, rt);




path_t = 0:dt:rt;



path = [path_t', path_qa', dpath_qa', ddpath_qa'];

%plot(path_t,path_qa,path_t,dpath_qa,path_t,ddpath_qa)


 