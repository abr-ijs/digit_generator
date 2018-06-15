function [slike, ime]=generiranje_stevil(kk ,vektor_st, ozadje, save_slike)

% Izdelava slik in trajektorij nakljucno generiranih stevk od 0 do 10
% k = stevilo generiranih primerov za posamezno stevko
% vektor_st = vektor z izbrani stevkami za generacijo
% ozadje = generiranje ozadja (0,1)
% save_slike = shranjevanje generiranih podatkov v datoteko (0,1)

% Zahtevane funkcije: devet programov st_*, izris_stevila, rand_number,
% st_2del, narisi_st, affina_tr, set DMP funkcij
%% Izbira parametrov
if nargin<3
    ozadje = 0;
end

%casovni korak trajektorije in DMP parametri
dt = 0.01;
DMP.N = 25; 
DMP.dt = dt; 
DMP.a_z = 48; 
DMP.a_x = 2;
DMP.tau=3;
%velikost slike v bitih in osnovna debelina èrte
izris.im_size_x = 40;
izris.im_size_y = 40;
izris.debelina=1.2;

%visina, sirina, rotacija, translacija trajektorije stevke
postavitev.h = 4;
postavitev.w = 2;
postavitev.r = 0;
postavitev.t = 0;


% Izris, debelina crte in gauss filter
ploting=0;
debelina_s=1.2;
sigma_d=0;
gauss=0.5;

% Priprava za generiranje ozadja
b=40-1;    
[x, y]=meshgrid(0:1:b,0:1:b); 
     
%% Generiranje trening podatkov

h = waitbar(0,'Generiranje stevk');


for k=1:kk 
    
    for r=1:length(vektor_st)  
        
        st=vektor_st(r);  

        i=(k-1)*length(vektor_st)+r;

        % Variacija parametrov transformacije slike 
        izris.debelina = debelina_s+rand_number()*sigma_d;

        parametri_tr.theta = rand_number()*8*pi/180;

        parametri_tr.x = rand_number()*3;
        
        parametri_tr.y = rand_number()*3;
        
        parametri_tr.xs = 1+rand_number()*0.1;
        
        parametri_tr.ys = 1+rand_number()*0.1;
        
        parametri_tr.ysh = rand_number()*0.1;


        %Generiranje DMP parametrov trajektorije posameznih stevk
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

        

        % Izdelava slike in trajektorije
        [slike.im{i}, slike.trj{i}] = narisi_st(DMP,izris,0); 

        %Filtriranje slike
        slike.im{i}=imgaussfilt(slike.im{i},gauss);
        
        %Affina transformacija
        [slike.im{i}, slike.trj{i}]=affina_tr(slike.im{i},slike.trj{i},parametri_tr,ploting);
        
        %Hitrosti in pospeski
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
       
       
       
       
       
       
       
        if ozadje==1;
            % Zeljena pozicija maksimuma
            xc=13*rand_number(); 
            yc=13*rand_number();

            % Sistemska matrika
            A=[xc 0 xc/2 1 0 0;...
               0 yc yc/2 0 1 0;... 
               b^2 0 0 b 0 1;... 
               0 b^2 0 0 b 1;... 
               b^2 b^2 b^2 b b 1;... 
               0 0 0 0 0 1];

           %Vrednosti
            n=[0 0 1*rand_number() 1*rand_number() 1*rand_number() 1*rand_number()];

            % Izracun ozadja
            r=A\n';

            axx=r(1);
            ayy=r(2);
            ax=r(4);
            ay=r(5);
            axy=r(3);
            n=r(6);
            z=axx*x.^2+ax*x+ayy*y.^2+ay*y+axy*x.*y+n;

            % Normalizacija ozadja
            Z=z;
            Zn = (Z-min(Z(:)))./(max(Z(:))-min(Z(:)));     
            Zn =Zn/(1-0.3)+0.3 ;

            
            IM=-slike.im{i}+1;

            slike.im{i}=IM.*Zn;
        end
        
            waitbar(i/(kk*length(vektor_st)),h)		
    end
  

    
end

close(h)

slike.id=rand*1000; % Identifikacija seta podatkov
slike.date=datetime;




slike.opis=['slike_' '[' num2str(vektor_st) ']_' num2str(kk*length(vektor_st)) '.mat'];

% Izris vzorca
figure(6)

for i=1:min([28,kk*length(vektor_st)])
    
    subplot(4,7,i)
    
    imshow(slike.im{i})
    hold on
    p4=plot(slike.trj{i}(:,1),slike.trj{i}(:,2));
    p4.LineWidth = 1.5; 
end

%% Shrani podatke
if save_slike==1
    ime=['slike_' num2str(slike.id) '.mat'];
    opis=slike.opis;
    date=datestr(slike.date);
    save(ime,'slike','opis','date')  
end
