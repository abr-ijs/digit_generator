function [B, x_traj] = affinetransform(image, traj, TrajParams, visualize)

  tx=TrajParams.x;
  ty=TrajParams.y*(-1);
  sx= TrajParams.xs;
  sy= TrajParams.ys;
  shy=TrajParams.ysh;
  shx=0;
  theta=TrajParams.theta;

  T=[1 0 0;...
      0 1 0;...
      tx ty 1];
  R=[ cos(theta) sin(theta) 0;...
      -sin(theta) cos(theta) 0;...
     0 0 1];
  SC=[ sx 0 0;...
      0 sy 0;...
      0 0 1];
  SH=[ 1 shy 0;...
      shx 1 0;...
      0 0 1];
  M=SH*SC*R*T;

  if exist('OCTAVE_VERSION', 'builtin') ~= 0
    a = size(image,2)/2;
    b = size(image,1)/2;
    tform = maketform('affine', M);
    [B ,xl,yl] = imtransform(image, tform ,...
                             'vdata', [1-a,a], 'udata', [1-b,b],...
                             'xdata', [1-a,a], 'ydata', [1-b,b]);
  else
    cb_ref = imref2d(size(image));
    cb_ref.XWorldLimits = cb_ref.XWorldLimits-size(image,2)/2;
    cb_ref.YWorldLimits = cb_ref.YWorldLimits-size(image,1)/2;
    tform = affine2d(M);
    B = imwarp(image,cb_ref,tform,'OutputView', cb_ref);
  end

  traj_t = traj;
  traj_t(:,1) = traj(:,1) - size(image,2)/2;
  traj_t(:,2) = traj(:,2) - size(image,1)/2;
  x_traj = traj_t * M;
  x_traj(:,1) = x_traj(:,1) + size(image,2)/2;
  x_traj(:,2) = x_traj(:,2) + size(image,1)/2;

  if visualize
    figure
    subplot(2,1,1)
    imshow(image)
    hold on
    plot(traj(:,1),traj(:,2))

    subplot(2,1,2)
    imshow(B)

    hold on
    plot(x_traj(:,1),x_traj(:,2))
  end
