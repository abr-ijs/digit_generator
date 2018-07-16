function Data = generatedigits(nSamples, varargin)
%GENERATEDIGITS: Generate images and trajectories of synthetic MNIST digits.
%   GENERATEDIGITS generates images and draw trajectories with DMP parameters of
%   synthetic MNIST-esque numerical digits from 0 to 9.
%
%   DATA = GENERATEDIGITS(NSAMPLES) returns a data struct
%   containing NSAMPLES of generated image and trajectory data for each of
%   the digits 0-9.
%
%   Optional arguments may be specified as name/value pairs as follows:
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."DIGITS", DIGITSVAL...) allows
%   the digits that are generated to be specified, where DIGITARRAY is a
%   1D array of integers selected from 0-9, e.g. [0, 1, 2]. Defaults to
%   [0:9].
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."IMAGESIZE", IMAGESIZEVAL...)
%   allows the generated image size to be specified as a 1D,
%   2-element array, e.g. [28,28].  Defaults to [40,40].
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."NOISE", NOISEVAL...) allows
%   noise to be optionally added to the generated images, where
%   NOISEVAL is a string that may be specified as "gaussian-background",
%   "awgn", "motion-blur" or "reduced-contrast-and-awgn".  The last 3
%   are parameterized according to the noise generation used by the
%   n-MNIST (noisy MNIST) dataset of Basu et al. from LSU:
%   http://www.csc.lsu.edu/~saikat/n-mnist/
%   If set to [] or omitted, no noise will be added.
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."SAVEPATH", SAVEPATHVAL...)
%   allows a .mat file save path to be optionally specified for saving
%   the generated data to file. If set to [] or omitted, no file will be
%   saved. Defaults to [];
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."PLOT", PLOTVAL...)
%   where setting PLOTVAL to true will plot a set of example images from the
%   generated DATA, as well as a GUI progress bar.  Defaults to false.
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."PAR", PARVAL...)
%   enables parallel processing of data, where PARVAL is specified as an
%   integer that determines the pool size (cores/threads).  If set to [],
%   0, 1, or omitted, parallel processing will be disabled.
%
%   DATA = GENERATEDIGITS(NSAMPLES, ..."SPLIT", SPLITVAL...)
%   allows for the generation of randomized training, validation and
%   test split indices of the generated dataset, where SPLITVAL is
%   specified as a 2-element or 3-element array of real values <= 1
%   determining relative percentages, e.g. [0.7,0.3] for 70% training data
%   and 30% test data or [0.7, 0.15, 0.15] for 70% training data,
%   15% validation data and 15% test data.  The seed used for randomization
%   is stored within the generated data struct alongside the indices.
%   If set to [] or omitted, no split will be generated. Defaults to [];
%
%   Required Matlab functions: devet programov st_*, izris_stevila, rand_number,
%   st_2del, narisi_st, affina_tr, set DMP funkcij
%
%   Copyright (C) 2018 Rok Pahič, Barry Ridge
%   Jožef Stefan Institute, Slovenia.
%   ATR Computational Neuroscience Laboratories, Japan.

    %% Set defaults
    defaultDigits = [0:9];
    defaultImageSize = [40,40];
    defaultNoise = [];
    expectedNoiseValues = {'gaussian-background', 'awgn', 'motion-blur',...
                           'reduced-contrast-and-awgn'};
    defaultSavePath = [];
    defaultPlot = false;
    defaultPar = [];
    defaultSplit = [];

    %% Parse arguments
    args = inputParser;
    addRequired(args,'nSamples', @(x) isnumeric(x) && isscalar(x) && x >= 1);
    addParameter(args, 'digits', defaultDigits,...
                 @(x) isnumeric(x) && size(x,1) == 1 && 1 <= size(x,2) <= 10 &&...
                      all(ismember(x, [0:9])));
    addParameter(args, 'imageSize', defaultImageSize,...
                 @(x) isnumeric(x) && size(x,1) == 1 && size(x,2) == 2 &&...
                      x(1) >= 1 && x(2) >= 1);
    addParameter(args, 'noise', defaultNoise,...
                 @(x) isempty(x) || any(validatestring(x, expectedNoiseValues)));
    addParameter(args, 'savePath', defaultSavePath,...
                 @(x) isempty(x) || ischar(x));
    addParameter(args, 'plot', defaultPlot, @islogical);
    addParameter(args, 'par', defaultPar,...
                 @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0));
    addParameter(args, 'split', defaultSplit,...
                 @(x) isempty(x) || (isnumeric(x) && size(x,1) == 1 &&...
                                     2 <= size(x,2) <= 3 && all(x <= 1.0)));
    parse(args, nSamples, varargin{:});

    %% Check for Octave
    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        isOctave = true;
    else
        isOctave = false;
    end

    %% Time step and DMP parameters
    dt = 0.01;
    DMP.N = 25;
    DMP.dt = dt;
    DMP.a_z = 48;
    DMP.a_x = 2;
    DMP.tau = 3;

    %% Image size in pixels
    PlotOut.im_size_x = args.Results.imageSize(1);
    PlotOut.im_size_y = args.Results.imageSize(2);

    %% Height, width, rotation and translation of initial digit
    layout.h = 4;
    layout.w = 2;
    layout.r = 0;
    layout.t = 0;

    %% Digit Gaussian filter and line width in pixels
    plotting = 0;
    width = 1.0;
    sigma_d = 0;
    gauss = 0.1;

    %% Prepare image background
    a = PlotOut.im_size_x - 1;
    b = PlotOut.im_size_y - 1;
    [gridX, gridY] = meshgrid(0:1:a, 0:1:b);

    %% Prepare to report progress
    if args.Results.plot && (isempty(args.Results.par) || args.Results.par <= 1)
        hWaitBar = waitbar(0,'Generating digits');
    else
        reverseStr = '';
    end
    
    %% Prepare cell arrays for the generated data
    imageArray = cell(1, args.Results.nSamples * length(args.Results.digits));
    trajArray = cell(1, args.Results.nSamples * length(args.Results.digits));
    DMPParamsArray = cell(1, args.Results.nSamples * length(args.Results.digits));
    DMPTrajArray = cell(1, args.Results.nSamples * length(args.Results.digits));
    
    %% Generate
    % Matlab parallel execution
    if ~isempty(args.Results.par) && args.Results.par > 1 && ~isOctave
        % Prepare parallel pool
        if args.Results.par > feature('numCores')
            fprintf('Requested par value exceeds maximum number of available local cores (%d)!\n',...
                    feature('numCores'));
            fprintf('Downscaling parallel pool to %d cores.\n', feature('numCores'));
            hPool = parpool(feature('numCores'));
        else
            hPool = parpool(args.Results.par);
        end
    
        nSamples = args.Results.nSamples * length(args.Results.digits);
        parfor iSample = 1:nSamples
            % Select a digit
            iDigit = mod(iSample - 1, length(args.Results.digits)) + 1;
            digit = args.Results.digits(iDigit);

            % Generate a sample of the digit
            [imageArray{iSample}, trajArray{iSample},...
             DMPParamsArray{iSample}, DMPTrajArray{iSample}] =...
                generatedigit(digit, args, dt, DMP, PlotOut, layout,...
                              plotting, width, sigma_d, gauss, gridX, gridY);
                          
            % Report progress
            if args.Results.plot
                fprintf('Generated sample %d of %d.\n', iSample, nSamples);
            end 
        end
        
        % Close parallel pool
        delete(hPool);
        
    % Octave parallel execution
    elseif ~isempty(args.Results.par) && args.Results.par > 1 && isOctave
        
    % Serial execution
    else
        for iSample = 1:(args.Results.nSamples * length(args.Results.digits))
            % Select a digit
            iDigit = mod(iSample - 1, length(args.Results.digits)) + 1;
            digit = args.Results.digits(iDigit);

            % Generate a sample of the digit
            [imageArray{iSample}, trajArray{iSample},...
             DMPParamsArray{iSample}, DMPTrajArray{iSample}] =...
                generatedigit(digit, args, dt, DMP, PlotOut, layout,...
                              plotting, width, sigma_d, gauss, gridX, gridY);

            % Report progress
            if args.Results.plot
                waitbar(iSample / (args.Results.nSamples * length(args.Results.digits)), hWaitBar);
            else
               percentDone = 100 * iSample / (args.Results.nSamples * length(args.Results.digits));
               msg = sprintf('Percent done: %3.1f', percentDone);
               fprintf([reverseStr, msg]);
               reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
    end
    
    %% Fill out Data struct
    Data.im = imageArray;
    Data.trj = trajArray;
    Data.DMP_object = DMPParamsArray;
    Data.DMP_trj = DMPTrajArray;

    %% Close progress bar
    if args.Results.plot && (isempty(args.Results.par) || args.Results.par <= 1)
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
    if args.Results.plot
        figure(6);

        for i = 1:min([12, args.Results.nSamples * length(args.Results.digits)])
            subplot(3,4,i)

            imshow(Data.im{i})
            hold on
            p4 = plot(Data.trj{i}(:,1),Data.trj{i}(:,2));
            %p4.LineWidth = 1; 
        end
    end

    %% Save generated Data to file
    if ~isempty(args.Results.savePath)
        Data.opis = args.Results.savePath;
        opis = Data.opis;
        date_time = datestr(Data.date);
        save(args.Results.savePath,'Data','opis','date_time')  
    end
end

%% Functions
%GENERATEDIGIT: Generate an image and trajectory for a specified digit.
%   GENERATEDIGIT generates a synthetic MNIST-esque image and draw
%   trajectory with DMP parameters for the specified numerical digit.
function [image, traj, DMPParams, DMPTraj] =...
    generatedigit(digit, args, dt, DMP, PlotOut, layout,...
                  plotting, width, sigma_d, gauss, gridX, gridY)
              
    %% Check for Octave
    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        isOctave = true;
    else
        isOctave = false;
    end

    % Variation of parameters for image transformation
    PlotOut.debelina = width + rand_number() * sigma_d;

    parametri_tr.theta = rand_number()*8*pi/180;
    parametri_tr.x = rand_number()*3;
    parametri_tr.y = rand_number()*3;
    parametri_tr.xs = 1+rand_number()*0.1;
    parametri_tr.ys = 1+rand_number()*0.1;
    parametri_tr.ysh = rand_number()*0.1;

    % Generate DMP parameters
    hDigitFunction = str2func(['st_', num2str(digit)]);
    DMP = hDigitFunction(layout, DMP, plotting);

    % Generate image and trajectory
    [image, traj] = narisi_st(DMP, PlotOut, 0); 

    % Gaussian filtering of image
    if isOctave
      image = imsmooth(image, gauss);
    else
      image = imgaussfilt(image, gauss);
    end

    % Affine transformation
    [image, traj] = affina_tr(image, traj, parametri_tr, plotting);

    % Velocity and acceleration
    vx = gradient(traj(:,1), dt);
    vy = gradient(traj(:,2), dt);
    ax = gradient(vx, dt);
    ay = gradient(vy, dt);

    path = [(0:dt:dt*(length(traj)-1))', traj(:,1), traj(:,2), vx, vy, ax, ay];
    % minus for y and vy!!
    
    % DMP
    DMPParams = DMP_reconstruct_adapted(path(:,2:3), path(:,4:5), path(:,6:7), path(:,1), DMP);

    [t_res, y_res] = DMP_track_adapted(DMPParams, DMPParams.y0, DMPParams.dt);
    DMPTraj = y_res(:,1:2);

    %% Noise generation
    if strcmpi(args.Results.noise, 'gaussian-background')
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
        x = gridX;
        y = gridY;
        z = axx*x.^2 + ax * x + ayy*y.^2 + ay*y + axy*x.*y + n;

        % Normalization
        Z = z;
        Zn = (Z - min(Z(:))) ./ (max(Z(:)) - min(Z(:)));
        Zn = Zn / (1 - 0.3) + 0.3;

        IM = -image + 1;

        image = IM .* Zn;
        
    elseif strcmpi(args.Results.noise, 'awgn')     
        % Normalize image
        I = image;
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Add additive white Gaussian noise with a signal-to-noise ratio of 9.5.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        image = awgn(I, 9.5);
        
    elseif strcmpi(args.Results.noise, 'motion-blur')
        % Normalize image
        I = image;
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Apply a linear camera motion of 5 pixels 15 degrees in the
        % counter-clockwise direction.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        H = fspecial('motion', 5, 15);
        image = imfilter(I, H, 'replicate');
        
    elseif strcmpi(args.Results.noise, 'reduced-contrast-and-awgn')     
        % Normalize image
        I = image;
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Reduce contrast range by 50%.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        I = imadjust(I, [0.0,1.0], [0.0,0.5]);
        
        % Add additive white Gaussian noise with a signal-to-noise ratio of 12.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        image = awgn(I, 12);
    end
end