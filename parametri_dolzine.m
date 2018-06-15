function q = parametri_dolzine(A)
% Funkcija izracuna razdaljo med posameznimi tockami in normalizira od 0 do
% 1

%%
q(1)=0;
for i=1:(size(A,1)-1)
    
    q(i+1) = q(i) + norm(A(i,:) - A(i+1,:));
    
end

q=q./q(end);