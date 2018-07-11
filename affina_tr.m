function [B, x_trj] =affina_tr(Slika_I,trj,parametri_tr,ploting)

tx=parametri_tr.x;
ty=parametri_tr.y*(-1);
sx= parametri_tr.xs;
sy= parametri_tr.ys;
shy=parametri_tr.ysh;
shx=0;
theta=parametri_tr.theta;

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
  x_min = 1 - size(Slika_I,1)/2;
  x_max = size(Slika_I,1) - (size(Slika_I,1)/2);
  y_min = 1 - size(Slika_I,2)/2;
  y_max = size(Slika_I,2) - (size(Slika_I,2)/2);
  [X,Y] = meshgrid(x_min:x_max,y_min:y_max);
  [X,Y] = meshgrid(1:size(Slika_I,1),1:size(Slika_I,2));
  [sy, sx] = size(X);
  D = [X(:), Y(:), ones(sx*sy, 1)]';
  MD = inv(M)*D;
  XI = MD(1,:)./MD(3,:);
  YI = MD(2,:)./MD(3,:);
  XI = reshape(XI, sy, sx);
  YI = reshape(YI, sy, sx);
  [B, valid] = imremap(Slika_I, XI, YI);
else
  cb_ref = imref2d(size(Slika_I));
  cb_ref.XWorldLimits=cb_ref.XWorldLimits-size(Slika_I,1)/2;
  cb_ref.YWorldLimits=cb_ref.YWorldLimits-size(Slika_I,1)/2;
  tform=affine2d(M);
  B=imwarp(Slika_I,cb_ref,tform,'OutputView',cb_ref);
end

slike.trj_t=trj;
slike.trj_t(:,1:2)=trj(:,1:2)-size(Slika_I,1)/2;
x_trj=(slike.trj_t*M);
x_trj=x_trj+size(Slika_I,1)/2;

if ploting
figure
subplot(2,1,1)
imshow(Slika_I)
hold on
plot(trj(:,1),trj(:,2))

subplot(2,1,2)
imshow(B)

hold on
plot(x_trj(:,1),x_trj(:,2))
end
