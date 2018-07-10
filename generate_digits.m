function [slike, ime]=generate_digits(digit_exampels ,digit_vector, noisy_background, save_images)

%% Generating images and trajectories with DMP parameters of digits from 0 to 10 
% digit_exampels = how many exampels of each digit shuld be generated
% digit_vector = whic digits shuld be generated
% noisy_background = generating background noise(0,1)
% save_images = saving images into file (0,1)

% Required matlab funtions: devet programov st_*, izris_stevila, rand_number,
% st_2del, narisi_st, affina_tr, set DMP funkcij
%% Parameter set
if nargin<3
    noisy_background = 0;
end

%time step and DMP parameters
dt = 0.01;
DMP.N = 25; 
DMP.dt = dt; 
DMP.a_z = 48; 
DMP.a_x = 2;
DMP.tau=3;

%Image size in bits
izris.im_size_x = 40;
izris.im_size_y = 40;


%Hight, wide, rotation and translation of initial digit
postavitev.h = 4;
postavitev.w = 2;
postavitev.r = 0;
postavitev.t = 0;


%Gauss filter  and line wide in bits
ploting=0;
debelina_s=1.0;
sigma_d=0;
gauss=0.1;

% Preparing for background
b=40-1;    
[x, y]=meshgrid(0:1:b,0:1:b); 
     
%% Generating training data

h = waitbar(0,'Generating digits');


for k=1:digit_exampels 
    
    for r=1:length(digit_vector)  
        
        st=digit_vector(r);  

        i=(k-1)*length(digit_vector)+r;

        % Varition of parameters for image transformation
        izris.debelina = debelina_s+rand_number()*sigma_d;

        parametri_tr.theta = rand_number()*8*pi/180;

        parametri_tr.x = rand_number()*3;
        
        parametri_tr.y = rand_number()*3;
        
        parametri_tr.xs = 1+rand_number()*0.1;
        
        parametri_tr.ys = 1+rand_number()*0.1;
        
        parametri_tr.ysh = rand_number()*0.1;


        %Generating DMP parameters
        if st==0
            DMP=st_0(postavitev,DMP,ploting);
        end
        
        if st==1
            DMP=st_1(postavitev,DMP,ploting);
        end
        
        if st==2
            DMP=st_2(postavitev,DMP,ploting);
        end
        
        if st==3
            DMP=st_3(postavitev,DMP,ploting);
        end
        
        if st==4
            DMP=st_4(postavitev,DMP,ploting);
        end
        
        if st==5
            DMP=st_5(postavitev,DMP,ploting);
        end
         
        if st==6
            DMP=st_6(postavitev,DMP,ploting);
        end
         
        if st==7
            DMP=st_7(postavitev,DMP,ploting);
        end
         
        if st==8
            DMP=st_8(postavitev,DMP,ploting);
        end
         
        if st==9
            DMP=st_9(postavitev,DMP,ploting);
        end

        

        % Generate image and trajectory
        [slike.im{i}, slike.trj{i}] = narisi_st(DMP,izris,0); 

        %Gausse filtering of image
        slike.im{i}=imgaussfilt(slike.im{i},gauss);
        
        %Affina transformation
        [slike.im{i}, slike.trj{i}]=affina_tr(slike.im{i},slike.trj{i},parametri_tr,ploting);
        
        %Velocity and aceleration
        vx=gradient(slike.trj{i}(:,1),dt);
        vy=gradient(slike.trj{i}(:,2),dt);
        ax=gradient(vx,dt);
        ay=gradient(vy,dt);


       path=[(0:dt:dt*(length(slike.trj{i})-1))',slike.trj{i}(:,1),slike.trj{i}(:,2),vx,vy,ax,ay];
% minus na y in vy!!
        %DMP
        slike.DMP_object{i} = DMP_reconstruct_adapted(path(:,2:3), path(:,4:5), path(:,6:7), path(:,1), DMP);

        [t_res, y_res] = DMP_track_adapted(slike.DMP_object{i},slike.DMP_object{i}.y0,slike.DMP_object{i}.dt);
       slike.DMP_trj{i}=y_res(:,1:2);
      %Sprememba: v trajektorijo se vpise original in ne DMP_trj
       %  slike.DMP_trj{i}=[slike.trj{i}(:,1),-slike.trj{i}(:,2)];
      
       
       %{
figure(6)

subplot(2,2,1)

plot(t_res,y_res(:,1:2),'b',t_res,slike.trj{i}(:,1:2),'r')
title('pot')
legend('dekodirana','dekodirana','original','original')

subplot(2,2,2)
v=gradient(slike.trj{i}(:,1:2)',dt);

plot(t_res,y_res(:,3:4),'b',t_res,v,'r')
title('hitrost')
subplot(2,2,3)

plot(y_res(:,1),-y_res(:,2),'b',slike.trj{i}(:,1),-slike.trj{i}(:,2),'r')
title('izris')
subplot(2,2,4)
av1=gradient(v,dt);
av2=gradient(y_res(:,3:4)',dt);
plot(t_res,av2,'b',t_res,av1,'r')
title('pospeski')

figure(6)
plot(DMP_object.w,'+')
hold on
plot(test.DMP_object{i}.w,'.')
title('utezi')
%}
       
       
       
       
       
%% Backgraund generation       
       
        if noisy_background==1
            % Desired maximum position
            xc=13*rand_number(); 
            yc=13*rand_number();

            % Sistem matrix
            A=[xc 0 xc/2 1 0 0;...
               0 yc yc/2 0 1 0;... 
               b^2 0 0 b 0 1;... 
               0 b^2 0 0 b 1;... 
               b^2 b^2 b^2 b b 1;... 
               0 0 0 0 0 1];

           %Values
            n=[0 0 1*rand_number() 1*rand_number() 1*rand_number() 1*rand_number()];

            %Calculating backgraund
            r=A\n';

            axx=r(1);
            ayy=r(2);
            ax=r(4);
            ay=r(5);
            axy=r(3);
            n=r(6);
            z=axx*x.^2+ax*x+ayy*y.^2+ay*y+axy*x.*y+n;

            % Normalization
            Z=z;
            Zn = (Z-min(Z(:)))./(max(Z(:))-min(Z(:)));     
            Zn =Zn/(1-0.3)+0.3 ;

            
            IM=-slike.im{i}+1;

            slike.im{i}=IM.*Zn;
        end
        
            waitbar(i/(digit_exampels*length(digit_vector)),h)		
    end
  

    
end

close(h)

slike.id=rand*1000; % ID number
slike.date=datetime;




slike.opis=['slike_' '[' num2str(digit_vector) ']_' num2str(digit_exampels*length(digit_vector)) '.mat'];

% Plot example
figure(6)

for i=1:min([28,digit_exampels*length(digit_vector)])
    
    subplot(4,7,i)
    
    imshow(slike.im{i})
    hold on
    p4=plot(slike.trj{i}(:,1),slike.trj{i}(:,2));
    p4.LineWidth = 1.5; 
end

%% Save data
ime=['slike_' num2str(slike.id) '.mat'];
if save_images==1
    
    opis=slike.opis;
    date=datestr(slike.date);
    save(ime,'slike','opis','date')  
end
