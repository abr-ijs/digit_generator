function [B, x_traj] = affinetransform(image, traj, traj_params, visualize)

  tx=traj_params.x;
  ty=traj_params.y*(-1);
  sx= traj_params.xs;
  sy= traj_params.ys;
  shy=traj_params.ysh;
  shx=0;
  theta=traj_params.theta;

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
    incp = [1 1; size(image,1) 1; size(image,1)  size(image,2) ; 1 size(image,2)];
    udata = [min(incp(:,1)) max(incp(:,1))];
    vdata = [min(incp(:,2)) max(incp(:,2))];
    T1=[1 0 0;...
        0 1 0;...
        -20 -20 1];
    
    tform_1=maketform('affine',T1);
    [B1 ,xl,yl]= imtransform(image,tform_1);
    
    a=size(image,1)/2;
    b=size(image,2)/2;

    tform=maketform('affine',M);
    [B2 ,xl,yl]= imtransform(B1,tform ,'vdata',[1-a,a],'udata', [1-b,b],'xdata',[1-a,a],'ydata', [1-b,b]);

    T1=[1 0 0;...
        0 1 0;...
        20 20 1];
    
    tform_1=maketform('affine',T1);
    [B,xl,yl]= imtransform(B2,tform_1,'vdata',[1-a,a],'udata', [1-b,b],'xdata',[1,size(image,1)],'ydata', [1,size(image,2)]);
    
  else
    cb_ref = imref2d(size(image));
    cb_ref.XWorldLimits=cb_ref.XWorldLimits-size(image,1)/2;
    cb_ref.YWorldLimits=cb_ref.YWorldLimits-size(image,1)/2;
    tform=affine2d(M);
    B=imwarp(image,cb_ref,tform,'OutputView',cb_ref);
  end

  slike.traj_t=traj;
  slike.traj_t(:,1:2)=traj(:,1:2)-size(image,1)/2;
  x_traj=(slike.traj_t*M);
  x_traj=x_traj+size(image,1)/2;

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
