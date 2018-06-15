function [slika_g, v]=narisi_st(DMP_object,izris,risi)
x=izris.im_size_x;
y=izris.im_size_y;
 slika=zeros(x,y);
%slika=rand(x,y);





trj=DMP_object.DMP_trj;
%plot(trj(:,2),trj(:,3))




piksel_trj=trj(:,2:3)/7*x+repmat([x/2,y/2],[length(trj),1]);
% plot(piksel_trj(:,1),piksel_trj(:,2))
% axis equal



for t=1:length(piksel_trj)
xc=piksel_trj(t,1);
yc=piksel_trj(t,2);

r=izris.debelina;
for xi=1:x
    for yi=1:y
        r_i=sqrt((xi-xc)^2+(yi-yc)^2);
        if r_i<r
            slika(y+1-yi,xi)=1;
        end
    end
end
end
% image(copic)
% slika=slika+copic;
slika_g=slika;
% slika_g=(slika-1)*(-1);

v(:,2)=-1*piksel_trj(:,2)+y+1;
v(:,1)=piksel_trj(:,1);
v(:,3)=1;
if risi
imshow(slika_g);
hold on

plot(v(:,1),v(:,2))

end
%imshow(slika)
%axis equal