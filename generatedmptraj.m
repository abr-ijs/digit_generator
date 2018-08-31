function DMP_object = generatedmptraj(A, DMP, visualize)
% This function is used as the second part of the program in generating all
% the numbers. It generates a DMP trajectory from the desired points.

% A = points on the trajectory
% DMP = DMP data
% visualize = plotting option 

  %% Visualize points
  if visualize
      plot(A(:,1),A(:,2))
      axis equal
      hold on
      scatter(A(:,1),A(:,2))
  end

  %% Regression
  q = pointdistances(A); % Calculate the distance between the points
  sq = Minimal_jerk_1D(0,1,DMP.dt,DMP.tau);  % Minimal jerk from 0% to 100% trajectory path
  xq1 = sq(:,2);

  % Regression between selected points with data q and A,
  % and calculation of values for points xq1
  p = pchip(q,A(:,1),xq1);
  k = pchip(q,A(:,2),xq1);

  % Plot regression
  if visualize
      plot(p,k)
      axis equal
  end

  % Generate a vector of paths with speeds and accelerations for the calculation of DMP
  % vx = gradient(p,DMP.dt);
  % vy = gradient(k,DMP.dt);
  % ax = gradient(vx,DMP.dt);
  % ay = gradient(vy,DMP.dt);
  % trj = [sq(:,1),p,k,vx,vy,ax,ay];
  % 
  % if visualize
  %     animatedigit(trj)
  % end
  %% Izracun DMP
  % path=trj;
  %  
  % DMP_object = DMP_reconstruct_adapted(path(:,2:3), path(:,4:5), path(:,6:7), path(:,1), DMP);
  % 
  % [t_res, y_res] = DMP_track_adapted(DMP_object, DMP_object.y0, DMP_object.dt);
  % 
  % % Plot DMP trajectory
  % if visualize
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
  %     animatedigit([t_res, y_res],2)
  % end

  % DMP_object.DMP_trj = [t_res, y_res];
  DMP_object = DMP;
  DMP_object.DMP_trj = [sq(:,1),p,k];
