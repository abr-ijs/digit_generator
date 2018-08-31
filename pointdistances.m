function q = pointdistances(A)
% The function calculates the distances between the individual points and
% normalizes the total length between [0,1].

%%
  q(1) = 0;
  for i = 1:(size(A,1)-1)
      
      q(i+1) = q(i) + norm(A(i,:) - A(i+1,:));
      
  end

  q = q./q(end);