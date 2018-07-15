function Data = generatedigits(nSamples, varargin)
%GENERATEDIGITS: Generate images and trajectories of digits.
%   GENERATEDIGITS generates images and trajectories with DMP parameters of
%   numerical digits from 0 to 9.
%
%   DATA = GENERATEDIGITS(NSAMPLES) returns a data struct
%   containing NSAMPLES of generated image and trajectory data for each of
%   the digits 0-9.
%
%   DATA = GENERATEDIGITS(NSAMPLES, DIGITARRAY) returns a data struct
%   containing NSAMPLES of generated image and trajectory data for each
%   digit in DIGITARRAY, where DIGITARRAY is a 1D array of integers
%   selected from 0-9.
%
%   DATA = GENERATEDIGITS(NSAMPLES, DIGITARRAY, IMAGESIZE) allows the
%   generated IMAGESIZE to be specified as a 1D, 2-element array,
%   e.g. [28,28].  Defaults to [40,40].
%
%   DATA = GENERATEDIGITS(NSAMPLES, DIGITARRAY, IMAGESIZE, NOISETYPE) allows
%   NOISETYPE noise to be optionally added to the generated images, where
%   NOISETYPE is a string that may be specified as "gaussian-background",
%   "awgn", "motion-blur" or "reduced-contrast-and-awgn".
%
%   DATA = GENERATEDIGITS(NSAMPLES, DIGITARRAY, IMAGESIZE, NOISETYPE, SAVEPATH)
%   allows SAVEPATH to be optionally specified as a MAT file save path for
%   the generated DATA.
%
%   DATA = GENERATEDIGITS(NSAMPLES, DIGITARRAY, IMAGESIZE, NOISETYPE, SAVEPATH, PLOT)
%   where PLOT is set to true will plot a set of example images from the
%   generated DATA, as well as a GUI progress bar.
%
%   Required Matlab functions: devet programov st_*, izris_stevila, rand_number,
%   st_2del, narisi_st, affina_tr, set DMP funkcij
%
%   Copyright (C) 2018 Rok Pahič, Barry Ridge

% Parse arguments
if nargin < 2 || isempty(varargin{1})
    digitArray = 0:9;
else
    digitArray = varargin{1};
end

if nargin < 3 || isempty(varargin{2})
    imageSize = [40,40];
else
    imageSize = varargin{2};
end

if nargin < 4
    noiseType = [];
else
    noiseType = varargin{3};
end

if nargin < 5
    savePath = [];
else
    savePath = varargin{4};
end

if nargin < 6
    guiPlot = false;
else
    guiPlot = varargin{5};
end

% Check for Octave
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    isOctave = true;
else
    isOctave = false;
end

% Time step and DMP parameters
dt = 0.01;
DMP.N = 25; 
DMP.dt = dt; 
DMP.a_z = 48; 
DMP.a_x = 2;
DMP.tau=3;

% Image size in bits
plot_out.im_size_x = imageSize(1);
plot_out.im_size_y = imageSize(2);

% Height, width, rotation and translation of initial digit
layout.h = 4;
layout.w = 2;
layout.r = 0;
layout.t = 0;

% Gaussian filter and line width in bits
plotting = 0;
width = 1.0;
sigma_d = 0;
gauss = 0.1;

% Preparing for background
a = plot_out.im_size_x - 1;
b = plot_out.im_size_y - 1;
[x, y] = meshgrid(0:1:a, 0:1:b);

if guiPlot
    hWaitBar = waitbar(0,'Generating digits');
else
    reverseStr = '';
end

for k = 1:nSamples
  for r = 1:length(digitArray)
      
    st=digitArray(r);

    i=(k-1)*length(digitArray)+r;

    % Variation of parameters for image transformation
    plot_out.debelina = width + rand_number() * sigma_d;

    parametri_tr.theta = rand_number()*8*pi/180;
    parametri_tr.x = rand_number()*3;
    parametri_tr.y = rand_number()*3;
    parametri_tr.xs = 1+rand_number()*0.1;
    parametri_tr.ys = 1+rand_number()*0.1;
    parametri_tr.ysh = rand_number()*0.1;

    % Generate DMP parameters
    if st==0
        DMP=st_0(layout,DMP,plotting);
    end

    if st==1
        DMP=st_1(layout,DMP,plotting);
    end

    if st==2
        DMP=st_2(layout,DMP,plotting);
    end

    if st==3
        DMP=st_3(layout,DMP,plotting);
    end

    if st==4
        DMP=st_4(layout,DMP,plotting);
    end

    if st==5
        DMP=st_5(layout,DMP,plotting);
    end

    if st==6
        DMP=st_6(layout,DMP,plotting);
    end

    if st==7
        DMP=st_7(layout,DMP,plotting);
    end

    if st==8
        DMP=st_8(layout,DMP,plotting);
    end

    if st==9
        DMP=st_9(layout,DMP,plotting);
    end

    % Generate image and trajectory
    [Data.im{i}, Data.trj{i}] = narisi_st(DMP,plot_out,0); 

    % Gaussian filtering of image
    if isOctave
      Data.im{i} = imsmooth(Data.im{i},gauss);
    else
      Data.im{i} = imgaussfilt(Data.im{i},gauss);
    end

    % Affine transformation
    [Data.im{i}, Data.trj{i}] = affina_tr(Data.im{i}, Data.trj{i}, parametri_tr, plotting);

    % Velocity and acceleration
    vx = gradient(Data.trj{i}(:,1), dt);
    vy = gradient(Data.trj{i}(:,2), dt);
    ax = gradient(vx, dt);
    ay = gradient(vy, dt);

    path = [(0:dt:dt*(length(Data.trj{i})-1))',Data.trj{i}(:,1),Data.trj{i}(:,2),vx,vy,ax,ay];
    % minus for y and vy!!
    
    %DMP
    Data.DMP_object{i} = DMP_reconstruct_adapted(path(:,2:3), path(:,4:5), path(:,6:7), path(:,1), DMP);

    [t_res, y_res] = DMP_track_adapted(Data.DMP_object{i},Data.DMP_object{i}.y0,Data.DMP_object{i}.dt);
    Data.DMP_trj{i}=y_res(:,1:2);

    %% Noise generation
    if strcmpi(noiseType, 'gaussian-background')
        % Desired maximum position
        xc = 13 * rand_number(); 
        yc = 13 * rand_number();

        % System matrix
        A = [xc 0 xc/2 1 0 0;...
             0 yc yc/2 0 1 0;... 
             a^2 0 0 b 0 1;... 
             0 b^2 0 0 b 1;... 
             a^2 b^2 b^2 b b 1;... 
             0 0 0 0 0 1];

        % Values
        n = [0 0 1*rand_number() 1*rand_number() 1*rand_number() 1*rand_number()];

        % Calculate backgraund
        r = A\n';

        axx = r(1);
        ayy = r(2);
        ax = r(4);
        ay = r(5);
        axy = r(3);
        n = r(6);
        z = axx*x.^2 + ax * x + ayy*y.^2 + ay*y + axy*x.*y + n;

        % Normalization
        Z = z;
        Zn = (Z - min(Z(:))) ./ (max(Z(:)) - min(Z(:)));
        Zn = Zn / (1 - 0.3) + 0.3;

        IM = -Data.im{i} + 1;

        Data.im{i} = IM .* Zn;
        
    elseif strcmpi(noiseType, 'awgn')     
        % Normalize image
        I = Data.im{i};
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Add additive white Gaussian noise with a signal-to-noise ratio of 9.5.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        Data.im{i} = awgn(I, 9.5);
        
    elseif strcmpi(noiseType, 'motion-blur')
        % Normalize image
        I = Data.im{i};
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Apply a linear camera motion of 5 pixels 15 degrees in the
        % counter-clockwise direction.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        H = fspecial('motion', 5, 15);
        Data.im{i} = imfilter(I, H, 'replicate');
        
    elseif strcmpi(noiseType, 'reduced-contrast-and-awgn')     
        % Normalize image
        I = Data.im{i};
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Reduce contrast range by 50%.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        I = imadjust(I, [0.0,1.0], [0.0,0.5]);
        
        % Add additive white Gaussian noise with a signal-to-noise ratio of 12.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        Data.im{i} = awgn(I, 12);
    end

    if guiPlot
        waitbar(i / (nSamples * length(digitArray)), hWaitBar);
    else
        % Display the progress
       percentDone = 100 * i / (nSamples * length(digitArray));
       msg = sprintf('Percent done: %3.1f', percentDone); %Don't forget this semicolon
       fprintf([reverseStr, msg]);
       reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
  end
end

%% Close the progress bar
if guiPlot
    close(hWaitBar)
end

%% Save meta-data in generated Data struct
Data.id = rand*1000; % ID number
if isOctave
  Data.date = date;
else
  Data.date = datetime;
end

%% Plot examples
if guiPlot
    figure(6);

    for i = 1:min([12,nSamples*length(digitArray)])
        subplot(3,4,i)

        imshow(Data.im{i})
        hold on
        p4 = plot(Data.trj{i}(:,1),Data.trj{i}(:,2));
        %p4.LineWidth = 1; 
    end
end

%% Save generated Data to file
if ~isempty(savePath)
    Data.opis = savePath;
    opis = Data.opis;
    date_time = datestr(Data.date);
    save(savePath,'Data','opis','date_time')  
end