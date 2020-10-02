pauliObj = Pauli;

% Set parameters for this camera (Micro)
pauliObj.parameters.verbose = 1;
% pauliObj.parameters.imagesToLoad = {'AtomsM', 'AtomsDarkM', 'BrightM', 'BrightDarkM', 'DMD2'};
pauliObj.parameters.imagesToLoad = {'AtomsM', 'AtomsDarkM', 'BrightM', 'BrightDarkM'};
% pauliObj.parameters.imagesToCrop = pauliObj.parameters.imagesToLoad(1:end-1);
pauliObj.parameters.imagesToCrop = pauliObj.parameters.imagesToLoad(1:end);
pauliObj.parameters.imagesToSave = {};
pauliObj.parameters.crop = [0 0 0 0];

% DMD Flash Filtering
pauliObj.parameters.user.DMDFilter = false;
pauliObj.parameters.user.DMDTop = 100;
pauliObj.parameters.user.DMDBot = 400;
pauliObj.parameters.user.DMDLeft = 230;
pauliObj.parameters.user.DMDRight = 380;
pauliObj.parameters.user.DMDFlashLowerThresh = -Inf;
pauliObj.parameters.user.DMDFlashUpperThresh = Inf;
pauliObj.data.user.dmdsums = {};

% Set Parameters related to the current state of the setup
pauliObj.parameters.user.NA = 0.61;
pauliObj.parameters.user.Magnification = 14.76;
pauliObj.parameters.user.Csat = 57; % 20200818, see Labbook 20201001
pauliObj.parameters.user.PixelSize = 16e-6;
pauliObj.parameters.user.EffectivePixelSize = pauliObj.parameters.      ...
    user.PixelSize / pauliObj.parameters.user.Magnification;
pauliObj.parameters.user.GperA = 7.8444;
pauliObj.parameters.user.dirtyHack = 1;

% Set constants for this atomic species (Li6)
pauliObj.constants.user.m = 9.9883e-27; %kg
pauliObj.constants.user.lambda = 6.709773382e-7; %m
pauliObj.constants.user.gamma = 5.8724*1e6; %Hz
pauliObj.constants.user.vrecoil = 0.09886776; %m/s
pauliObj.constants.user.Isat = 25.4; %W/m²
pauliObj.constants.user.erecoil = (pauliObj.constants.hbar*2*pi* ...
    pauliObj.constants.user.lambda)^2/(2*pauliObj.constants.user.m); %J
pauliObj.constants.user.resonance_12 = 832.18; %G
pauliObj.constants.user.resonance_width_12 = -262.3; %G
pauliObj.constants.user.a_bg_12 = -1582*pauliObj.constants.a0; %m
pauliObj.constants.user.sigma = 3*pauliObj.constants.user.lambda^2/2/pi;

% Set some useful functions
pauliObj.constants.user.functions = struct();
pauliObj.constants.user.functions.kF_n = @(n) sqrt(4*pi*1e12*n);
pauliObj.constants.user.functions.TF_n_mol = @(n) ...
    pauliObj.constants.hbar^2 * ...
    pauliObj.constants.user.functions.kF_n(n)^2 ...
    / ( 2 * (2 * pauliObj.constants.user.m) ) / pauliObj.constants.kb *1e9;
pauliObj.constants.user.functions.TF_n_atom = @(n) 2 * ...
    pauliObj.constants.user.functions.TF_n_mol(n);
pauliObj.constants.user.functions.lz_nuz_mol = @(nuz) sqrt( ...
    pauliObj.constants.hbar / ((2 * pauliObj.constants.user.m) ...
    * 2 * pi * nuz));
pauliObj.constants.user.functions.lz_nuz_atom = @(nuz) sqrt(2) * ...
    pauliObj.constants.user.functions.lz_nuz_mol(nuz);
pauliObj.constants.user.functions.a2d0_lz_a3d = @(lz, a3d) lz ...
    .* sqrt(pi/0.905) .* exp( -sqrt(pi/2) * lz ./ a3d );
pauliObj.constants.user.functions.g_a3d_lz_mol = @(a3d, lz) ( ...
    pauliObj.constants.hbar^2 / 2 / pauliObj.constants.user.m ) ...
    * sqrt( 8 * pi ) * a3d / lz;
pauliObj.constants.user.functions.g_a3d_lz_atom = @(a3d, lz) ...
    2 * pauliObj.constants.user.functions.g_a3d_lz_mol(a3d, lz);
pauliObj.constants.user.functions.healinglength_g_n_mol = @(g, n) ...
    pauliObj.constants.hbar / sqrt(4*pauliObj.constants.user.m*g*n);
pauliObj.constants.user.functions.healinglength_g_n_atom = @(g, n) ...
    pauliObj.constants.hbar / sqrt(2*pauliObj.constants.user.m*g*n);
pauliObj.constants.user.functions.gtilde_a3d_lz = @(a3d, lz)  ...
    sqrt( 8 * pi ) * a3d / lz;

% Internal, dont modify
pauliObj.parameters.convertToDensityFunctionName = 'convertToDensity_HH_Li6_Micro';
pauliObj.saveConfig('Experiments\HH_Li6\Micro.pauli');

clear pauliObj;