function [image, v] = drawdigit(DMP_object, Options, visualize)
%DRAWDIGIT: Draw image and trajectory of synthetic MNIST digit DMP object.
%   DRAWDIGIT draws the digit image and trajectory of a given DMP object.
%
%   Copyright (C) 2018 Rok Pahič, Barry Ridge
%   Jožef Stefan Institute, Slovenia.
%   ATR Computational Neuroscience Laboratories, Japan.
  x = Options.im_size_x;
  y = Options.im_size_y;
  image = zeros(x,y);

  trj = DMP_object.DMP_trj;

  pixel_trj = trj(:,2:3)/7*x+repmat([x/2,y/2],[length(trj),1]);

  for t = 1:length(pixel_trj)
  xc = pixel_trj(t,1);
  yc = pixel_trj(t,2);

  r = Options.thickness;
  for xi = 1:x
      for yi = 1:y
          r_i = sqrt((xi-xc)^2+(yi-yc)^2);
          if r_i<r
              image(y+1-yi,xi) = 1;
          end
      end
  end
  end

  v(:,2) = -1 * pixel_trj(:,2) + y+1;
  v(:,1) = pixel_trj(:,1);
  v(:,3) = 1;
  
  if visualize
    imshow(image);
    hold on;
    plot(v(:,1),v(:,2));
  end
  