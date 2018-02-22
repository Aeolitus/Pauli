pauliObj = Pauli;

% Set parameters for this camera (Micro)
pauliObj.parameters.verbose = 1;
pauliObj.parameters.imagesToLoad = {'AtomsM', 'AtomsDarkM', 'BrightM', 'BrightDarkM'};
pauliObj.parameters.crop = [1 1 2 1];

% Set Parameters related to the current state of the setup
pauliObj.parameters.user.NA = 0.61;
pauliObj.parameters.user.Magnification = 30.8;
pauliObj.parameters.user.Csat = 31.58;
pauliObj.parameters.user.PixelSize = 16e-6;
pauliObj.parameters.user.EffectivePixelSize = pauliObj.parameters.      ...
    user.PixelSize / pauliObj.parameters.user.Magnification;
pauliObj.parameters.user.GperA = 7.92;

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

% Internal, dont modify
pauliObj.parameters.convertToDensityFunctionName = 'convertToDensity_HH_Li6_Micro';
pauliObj.saveConfig('Experiments\HH_Li6\Micro');

clear pauliObj;