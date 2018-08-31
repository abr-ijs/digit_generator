function animatedigit(trj, k, fr, demo)
% Animated digit plotting

%%
if nargin < 4
    demo = 0;
end

if nargin < 3
    fr = figure(33);
end

figure(fr);
hold on
axis equal

if demo == 1
   n = length(trj)/5;
   index = int32(linspace(1, length(trj), n));
   
   for i=1:n 
       pl = plot(trj(1:index(i),2), trj(1:index(i),3), 'r', 'LineWidth', 8);
       sc = scatter(trj(index(i),2), trj(index(i),3), [90], [1,0,0], 'o', 'filled');
       drawnow
       delete(sc)  
   end      
end
%!!! Watch out for minuses
p = plot(trj(:,2), trj(:,3), k, 'LineWidth', 6);
