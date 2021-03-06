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
%   DATA = GENERATEDIGITS(NSAMPLES, ..."TRANSFORM", TRANSFORMVAL...) allows
%   affine transform distortions to be optionally added to the generated images,
%   where TRANSFORMVAL is a string that may be specified as "rotated",
%   or "rotated-translated-and-scaled".  Both of these
%   are parameterized similarly to the transforms used in the
%   distorted MNIST datasets of Jaderberg et al. in the
%   Spatial Transformer Networks paper: https://arxiv.org/abs/1506.02025
%   The transformed images and trajectories will be stored separately from
%   original images and trajectories in the DATA struct.
%   If set to [] or omitted, the additional transformed images and trajectories
%   will not be generated.
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
%   DATA = GENERATEDIGITS(NSAMPLES, ..."WIDTH", WIDTHVAL...) allows
%   digits of fixed or varied line width to be generated,
%   where WIDTHVAL is a string that may be specified as "fixed",
%   or "varied". If set to [] or omitted, it defaults to "fixed".
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
%   Required Matlab functions: digit[0-9], animatedigit, rand_number,
%   generatedmptraj, drawdigit, affinetransform, set DMP functions
%
%   Copyright (C) 2018 Rok Pahič, Barry Ridge
%   Jožef Stefan Institute, Slovenia.
%   ATR Computational Neuroscience Laboratories, Japan.

    %% Set defaults
    defaultDigits = [0:9];
    defaultImageSize = [40,40];
    defaultTransform = [];
    expectedTransformValues = {'rotated', 'rotated-translated-and-scaled'};
    defaultNoise = [];
    expectedNoiseValues = {'gaussian-background', 'awgn', 'motion-blur',...
                           'reduced-contrast-and-awgn'};
    defaultWidth = [];
    expectedWidthValues = {'varied'};
    defaultSavePath = [];
    defaultPlot = false;
    defaultPar = [];
    defaultSplit = [];
    defaultSeed = [];

    %% Parse arguments
    args = inputParser;
    addRequired(args,'nSamples', @(x) isnumeric(x) && isscalar(x) && x >= 1);
    addParameter(args, 'digits', defaultDigits,...
                 @(x) isnumeric(x) && size(x,1) == 1 && 1 <= size(x,2) <= 10 &&...
                      all(ismember(x, [0:9])));
    addParameter(args, 'imageSize', defaultImageSize,...
                 @(x) isnumeric(x) && size(x,1) == 1 && size(x,2) == 2 &&...
                      x(1) >= 1 && x(2) >= 1);
    addParameter(args, 'transform', defaultTransform,...
                 @(x) isempty(x) || any(validatestring(x, expectedTransformValues)));
    addParameter(args, 'noise', defaultNoise,...
                 @(x) isempty(x) || any(validatestring(x, expectedNoiseValues)));
    addParameter(args, 'width', defaultWidth,...
                 @(x) isempty(x) || any(validatestring(x, expectedWidthValues)));
    addParameter(args, 'savePath', defaultSavePath,...
                 @(x) isempty(x) || ischar(x));
    addParameter(args, 'plot', defaultPlot, @islogical);
    addParameter(args, 'par', defaultPar,...
                 @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 0));
    addParameter(args, 'split', defaultSplit,...
                 @(x) isempty(x) || (isnumeric(x) && size(x,1) == 1 &&...
                                     2 <= size(x,2) <= 3 && all(x <= 1.0)));
    addParameter(args, 'seed', defaultSeed,...
                 @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x >= 1));
    parse(args, nSamples, varargin{:});

    %% Check for Octave
    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        isOctave = true;
    else
        isOctave = false;
    end

    %% Seed the random number generator
    if ~isempty(args.Results.seed)
      if isOctave
        rand('state', args.Results.seed);
      else
        rng(args.Results.seed, 'twister');
      end
    end

    %% Time step and DMP parameters
    dt = 0.01;
    DMP.N = 25;
    DMP.dt = dt;
    DMP.a_z = 48;
    DMP.a_x = 2;
    DMP.tau = 3;

    %% Image size in pixels
    DigitOptions.im_size_x = args.Results.imageSize(1);
    DigitOptions.im_size_y = args.Results.imageSize(2);

    %% Height, width, rotation and translation of initial digit
    layout.h = 4;
    layout.w = 2;
    layout.r = 0;
    layout.t = 0;

    %% Digit Gaussian filter and line width in pixels
    visualize = 0;
    width = 1.0;
    if !isempty(args.Results.width)
      if strcmpi(args.Results.width, 'varied')
        sigma_d = 0.5;
      else
        sigma_d = 0.0;
      endif
    else
      sigma_d = 0.0;
    endif
    gauss = 0.1;

    %% Prepare image background
    a = DigitOptions.im_size_x - 1;
    b = DigitOptions.im_size_y - 1;
    [gridX, gridY] = meshgrid(0:1:a, 0:1:b);

    %% Prepare to report progress
    if args.Results.plot && (isempty(args.Results.par) || args.Results.par <= 1)
        hWaitBar = waitbar(0,'Generating digits');
    else
        reverseStr = '';
    end
    
    %% Prepare cell arrays for the generated data
    nSamples = args.Results.nSamples * length(args.Results.digits);
    imageArray = cell(1, nSamples);
    trajArray = cell(1, nSamples);
    DMPParamsArray = cell(1, nSamples);
    DMPTrajArray = cell(1, nSamples);
    trans_imageArray = cell(1, nSamples);
    trans_trajArray = cell(1, nSamples);
    TransDMPParamsArray = cell(1, nSamples);
    TransDMPTrajArray = cell(1, nSamples);
    
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
        
        % Parallel execution
        parfor iSample = 1:nSamples
            % Select a digit
            iDigit = mod(iSample - 1, length(args.Results.digits)) + 1;
            digit = args.Results.digits(iDigit);

            % Generate a sample of the digit
            [imageArray{iSample}, trajArray{iSample},...
             DMPParamsArray{iSample}, DMPTrajArray{iSample},...
             trans_imageArray{iSample}, trans_trajArray{iSample},...
             TransDMPParamsArray{iSample}, TransDMPTrajArray{iSample}] =...
                generatedigit(digit, args, dt, DMP, DigitOptions, layout,...
                              visualize, width, sigma_d, gauss, gridX, gridY);
                          
            % Report progress
            if args.Results.plot
                fprintf('Generated sample %d of %d.\n', iSample, nSamples);
            end 
        end
        
        % Close parallel pool
        delete(hPool);
        
    % Octave parallel execution
    elseif ~isempty(args.Results.par) && args.Results.par > 1 && isOctave
        % Generate a digit type array for the whole dataset
        for iSample = 1:nSamples
            iDigit = mod(iSample - 1, length(args.Results.digits)) + 1;
            digit = args.Results.digits(iDigit);
            digitArray(iSample) = digit;
        end

        % Parallel execution
        [imageArray, trajArray, DMPParamsArray, DMPTrajArray,...
         trans_imageArray, trans_trajArray, TransDMPParamsArray, TransDMPTrajArray] =...
            pararrayfun(args.Results.par,...
                        @(iSample) generatedigit(digitArray(iSample), args, dt, DMP, DigitOptions, layout,...
                                                 visualize, width, sigma_d, gauss, gridX, gridY),...
                        1:length(digitArray),...
                        "UniformOutput", false);                        
                          
    % Serial execution
    else
        for iSample = 1:nSamples
            % Select a digit
            iDigit = mod(iSample - 1, length(args.Results.digits)) + 1;
            digit = args.Results.digits(iDigit);

            % Generate a sample of the digit
            [imageArray{iSample}, trajArray{iSample},...
             DMPParamsArray{iSample}, DMPTrajArray{iSample},...
             trans_imageArray{iSample}, trans_trajArray{iSample},...
             TransDMPParamsArray{iSample}, TransDMPTrajArray{iSample}] =...
                generatedigit(digit, args, dt, DMP, DigitOptions, layout,...
                              visualize, width, sigma_d, gauss, gridX, gridY);

            % Report progress
            if args.Results.plot
                waitbar(iSample / nSamples, hWaitBar);
            else
               percentDone = 100 * (iSample / nSamples);
               msg = sprintf('Percent done: %3.1f', percentDone);
               fprintf([reverseStr, msg]);
               reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
    end
    
    %% Fill out Data struct
    Data.imageArray = imageArray;
    Data.trajArray = trajArray;
    Data.DMPParamsArray = DMPParamsArray;
    Data.DMPTrajArray = DMPTrajArray;
    Data.trans_imageArray = trans_imageArray;
    Data.trans_trajArray = trans_trajArray;
    Data.TransDMPParamsArray = TransDMPParamsArray;
    Data.TransDMPTrajArray = TransDMPTrajArray;

    %% Close progress bar
    if args.Results.plot && (isempty(args.Results.par) || args.Results.par <= 1)
        close(hWaitBar)
    end

    %% Save meta-data in generated Data struct
    if isOctave
      Data.date = strftime ("%Y-%b-%d %H:%M:%S", localtime (time ()));
    else
      Data.date = datestr(datetime);
    end
    Data.filename = args.Results.savePath;

    %% Plot examples
    if args.Results.plot
        figure;

        for i = 1:min([12, args.Results.nSamples * length(args.Results.digits)])
            subplot(3,4,i)

            imshow(Data.imageArray{i})
            hold on
            p4 = plot(Data.trajArray{i}(:,1), Data.trajArray{i}(:,2));
            %p4.LineWidth = 1; 
        end
        
        if ~isempty(Data.trans_imageArray)
          figure;

          for i = 1:min([12, args.Results.nSamples * length(args.Results.digits)])
              subplot(3,4,i)

              imshow(Data.trans_imageArray{i})
              hold on
              plot(Data.trans_trajArray{i}(:,1), Data.trans_trajArray{i}(:,2));
          end
        end
    end

    %% Save generated Data to file
    if ~isempty(args.Results.savePath)
        if isOctave
          % Octave V7 mat file saving borks the scipy.io loader
          save(args.Results.savePath, 'Data', '-v6');
        else
          save(args.Results.savePath, 'Data');
        end
    end
end

%% Functions
%GENERATEDIGIT: Generate an image and trajectory for a specified digit.
%   GENERATEDIGIT generates a synthetic MNIST-esque image and draw
%   trajectory with DMP parameters for the specified numerical digit.
function [image, traj, DMPParams, DMPTraj,...
          trans_image, trans_traj, TransDMPParams, TransDMPTraj] =...
    generatedigit(digit, args, dt, DMP, DigitOptions, layout,...
                  visualize, width, sigma_d, gauss, gridX, gridY)
              
    %% Check for Octave
    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        isOctave = true;
    else
        isOctave = false;
    end

    % Variation of parameters for image transformation
    DigitOptions.thickness = width + rand_number() * sigma_d;

    %% Default transform generation
    TrajParams.theta = rand_number()*8*pi/180;
    TrajParams.x = rand_number()*3;
    TrajParams.y = rand_number()*3;
    TrajParams.xs = 1+rand_number()*0.1;
    TrajParams.ys = 1+rand_number()*0.1;
    TrajParams.ysh = rand_number()*0.1;

    % Generate DMP parameters
    hDigitFunction = str2func(['digit', num2str(digit)]);
    DMP = hDigitFunction(layout, DMP, visualize);

    % Draw digit trajectory and digit image
    [image, traj] = drawdigit(DMP, DigitOptions, 0); 

    % Gaussian filtering of image
    if isOctave
      image = imsmooth(image, gauss);
    else
      image = imgaussfilt(image, gauss);
    end

    % Affine transformation
    [image, traj] = affinetransform(image, traj, TrajParams, visualize);

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
    
    %% Additional transform generation
    if !isempty(args.Results.transform)
      % Mimicking the 'rotated dataset (R)' from the Spatial Transformer
      % Networks paper: https://arxiv.org/abs/1506.02025
      if strcmpi(args.Results.transform, 'rotated')
        % Set transform parameters to transform with a random rotation sampled
        % uniformly between −90 and +90 degrees.
        TransTrajParams.theta = rand_number()*90*pi/180;
        TransTrajParams.x = 0;
        TransTrajParams.y = 0;
        TransTrajParams.xs = 1;
        TransTrajParams.ys = 1;
        TransTrajParams.ysh = 0;
        
        % Do the transform
        [trans_image, trans_traj] = affinetransform(image, traj, TransTrajParams, visualize);
      
      % Mimicking the 'rotated, translated and scaled dataset (RTS)' from the
      % Spatial Transformer Networks paper: https://arxiv.org/abs/1506.02025  
    elseif strcmpi(args.Results.transform, 'rotated-translated-and-scaled')
        % Set transform parameters to randomly rotate the digit by sampling
        % uniformly between -45 and +45 degrees and randomly scale the digit by
        % a factor of between 0.7 and 1.2.
        TransTrajParams.theta = rand_number()*45*pi/180;
        scaling_factor = (1.2-0.7)*rand + 0.7;
        TransTrajParams.x = 0;
        TransTrajParams.y = 0;
        TransTrajParams.xs = scaling_factor;
        TransTrajParams.ys = scaling_factor;
        TransTrajParams.ysh = 0;
        
        % Do the transform
        [trans_image, trans_traj] = affinetransform(image, traj, TransTrajParams, visualize);
        
        % Separately, create a new image with a black background scaled to be
        % 1.5 times the size of original image and insert the digit in a random
        % location within it (this mimicks the 28x28 -> 42x42 digit image insertion
        % of the RTS dataset in the STN paper).
        r = round(size(trans_image, 1) * 1.5);
        c = round(size(trans_image, 2) * 1.5);
        back_image = zeros(r,c);
        insert_r = round(((r - size(trans_image, 1)) - 1)*rand + 1);
        insert_c = round(((c - size(trans_image, 2)) - 1)*rand + 1);
        back_image(insert_r:insert_r+size(trans_image,1)-1,
                   insert_c:insert_c+size(trans_image,2)-1) = trans_image;
        trans_image = back_image;
        
        % In this case, the trajectory also needs to be translated.
        trans_traj(:,1) = trans_traj(:,1) + insert_c - 1;
        trans_traj(:,2) = trans_traj(:,2) + insert_r - 1;
        
      end
      
      % Velocity and acceleration
      vx = gradient(trans_traj(:,1), dt);
      vy = gradient(trans_traj(:,2), dt);
      ax = gradient(vx, dt);
      ay = gradient(vy, dt);

      trans_path = [(0:dt:dt*(length(trans_traj)-1))', trans_traj(:,1), trans_traj(:,2), vx, vy, ax, ay];
      % minus for y and vy!!
      
      % DMP
      TransDMPParams = DMP_reconstruct_adapted(trans_path(:,2:3),...
                                               trans_path(:,4:5),...
                                               trans_path(:,6:7),...
                                               trans_path(:,1), DMP);

      [trans_t_res, trans_y_res] = DMP_track_adapted(DMPParams, DMPParams.y0, DMPParams.dt);
      TransDMPTraj = trans_y_res(:,1:2);
      
    else
      trans_image = [];
      trans_traj = [];
      TransDMPParams = [];
      TransDMPTraj = [];
      
    end

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
        
        if !isempty(args.Results.transform)
          trans_IM = -trans_image + 1;
          trans_image = trans_IM .* Zn;
        endif
        
    elseif strcmpi(args.Results.noise, 'awgn')
        % Normalize image
        I = image;
        I = double(I);
        I = I - min(I(:));
        I = I / max(I(:));
        
        % Add additive white Gaussian noise with a signal-to-noise ratio of 9.5.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        image = awgn(I, 9.5);
        
        if !isempty(args.Results.transform)
          % Normalize image
          trans_I = trans_image;
          trans_I = double(trans_I);
          trans_I = trans_I - min(trans_I(:));
          trans_I = trans_I / max(trans_I(:));
          
          % Add additive white Gaussian noise with a signal-to-noise ratio of 9.5.
          % See: http://www.csc.lsu.edu/~saikat/n-mnist/
          trans_image = awgn(trans_I, 9.5);
        endif
        
    elseif strcmpi(args.Results.noise, 'motion-blur')
        % Normalize image
        I = image;
        I = double(I);
        I = I - min(I(:));visualize
        I = I / max(I(:));
        
        % Apply a linear camera motion of 5 pixels 15 degrees in the
        % counter-clockwise direction.
        % See: http://www.csc.lsu.edu/~saikat/n-mnist/
        H = fspecial('motion', 5, 15);
        image = imfilter(I, H, 'replicate');
        
        if !isempty(args.Results.transform)
          % Normalize image
          trans_I = trans_image;
          trans_I = double(trans_I);
          trans_I = trans_I - min(trans_I(:));
          trans_I = trans_I / max(trans_I(:));
          
          % Apply a linear camera motion of 5 pixels 15 degrees in the
          % counter-clockwise direction.
          % See: http://www.csc.lsu.edu/~saikat/n-mnist/
          trans_H = fspecial('motion', 5, 15);
          trans_image = imfilter(trans_I, trans_H, 'replicate');
        endif
        
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
        
        if !isempty(args.Results.transform)
          % Normalize image
          trans_I = trans_image;
          trans_I = double(trans_I);
          trans_I = trans_I - min(trans_I(:));
          trans_I = trans_I / max(trans_I(:));
          
          % Reduce contrast range by 50%.
          % See: http://www.csc.lsu.edu/~saikat/n-mnist/
          trans_I = imadjust(trans_I, [0.0,1.0], [0.0,0.5]);
          
          % Add additive white Gaussian noise with a signal-to-noise ratio of 12.
          % See: http://www.csc.lsu.edu/~saikat/n-mnist/
          trans_image = awgn(trans_I, 12);
        endif
    end
end
