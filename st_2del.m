function DMP_object=st_2del(A,DMP,ploting)
% Funkcija se uporablja kot drugi del programa pri generaciji vseh stevk
% Iz zeljenih tock generira DMP trajektorijo

% A = tocke na trajektoriji
% DMP = DMP podatki
% ploting = opcija izrisa 

%% Izris tock
if ploting
    plot(A(:,1),A(:,2))
    axis equal
    hold on
    scatter(A(:,1),A(:,2))
end

%% Regresija

q = parametri_dolzine(A); % Izracun razdalje med tockami
sq = Minimal_jerk_1D(0,1,DMP.dt,DMP.tau);  % Minimal jerk od 0% do 100% opravljene poti trajektorije
xq1 = sq(:,2);

% Regresija med izbranimi tockami z podatki q in A, in izracun vrednosti za
% tocke xq1
p = pchip(q,A(:,1),xq1);
k = pchip(q,A(:,2),xq1);

% Izris regresije
if ploting
    plot(p,k)
    axis equal
end

% Generiranje vektorja poti z hitrostmi in pospeski za izracun DMP
% vx = gradient(p,DMP.dt);
% vy = gradient(k,DMP.dt);
% ax = gradient(vx,DMP.dt);
% ay = gradient(vy,DMP.dt);
% trj = [sq(:,1),p,k,vx,vy,ax,ay];
% 
% if ploting
%     izris_stevila(trj)
% end
%% Izracun DMP
% path=trj;
%  
% DMP_object = DMP_reconstruct_adapted(path(:,2:3), path(:,4:5), path(:,6:7), path(:,1), DMP);
% 
% [t_res, y_res] = DMP_track_adapted(DMP_object, DMP_object.y0, DMP_object.dt);
% 
% % Izris DMP trajektorije
% if ploting
% 
%     figure(44)
%     
%     subplot(3,1,1)    
%     plot(path(:,1),path(:,2:3),'.')
%     hold on
%     plot(t_res, y_res(:,1:2))
% 
%     subplot(3,1,2)    
%     plot(path(:,1),path(:,4:5),'.')
%     hold on
%     plot(t_res, y_res(:,3:4))
% 
%     subplot(3,1,3)  
%     plot(path(:,1),path(:,6:7),'.')
%     hold on
%     plot(t_res, y_res(:,5:6))
% 
%     izris_stevila([t_res, y_res],2)
% end

% DMP_object.DMP_trj = [t_res, y_res];
DMP_object=DMP;
DMP_object.DMP_trj = [sq(:,1),p,k];
