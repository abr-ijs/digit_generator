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
  incp = [1 1; size(Slika_I,1) 1; size(Slika_I,1)  size(Slika_I,2) ; 1 size(Slika_I,2)];
 udata = [min(incp(:,1)) max(incp(:,1))];
 vdata = [min(incp(:,2)) max(incp(:,2))];
     T1=[1 0 0;...
    0 1 0;...
    -20 -20 1];
  
  tform_1=maketform('affine',T1);
  [B1 ,xl,yl]= imtransform(Slika_I,tform_1);
   
   
   
  


  


  tform=maketform('affine',M);
  [B2 ,xl,yl]= imtransform(B1,tform ,'vdata',[-19,20],'udata', [-19,20],'xdata',[-19,20],'ydata', [-19,20]);
 #imshow(B2)
   T1=[1 0 0;...
    0 1 0;...
    20 20 1];
  
  tform_1=maketform('affine',T1);
  [B,xl,yl]= imtransform(B2,tform_1,'vdata',[-19,20],'udata', [-19,20],'xdata',[1,40],'ydata', [1,40]);
  
  
  # imshow(B)
  
  
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
