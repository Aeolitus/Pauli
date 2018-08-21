function pauliObj = make_HH_Li6_Doubleshot()
% make_HH_Li6_Zyla    Experiment and Mode specific definition of parameters
%    This is the place where you define all the parameters and constants
%    specific to your Experiment and Mode. The values below are just listed
%    as an example and can (and should) all be modified by you. Only the
%    very last section titled "Internal Use" should stay as it is.
%    Call this method to reset the saved Pauli config file. Alternatively,
%    save the output of this method to a variable to receive a fresh Pauli
%    object with your settings.
pauliObj = Pauli;

%% Set parameters for this mode
% Output to console on
pauliObj.parameters.verbose = 1; 
% Shot Names to load from file system
pauliObj.parameters.imagesToLoad = {'AtomsD', 'BrightD', 'DarkAtomsD', 'DarkBrightD'}; 
% Shot Names to keep after converting to density
pauliObj.parameters.imagesToSave = {};
% How many pixels to crop from the images [Left, Right, Top, Bottom]
pauliObj.parameters.crop = [0 0 0 0];

%% Set user parameters related to the current state of the setup
pauliObj.parameters.user.NA = 0.61;
pauliObj.parameters.user.Magnification = 30.8;
pauliObj.parameters.user.Csat = 1250;
pauliObj.parameters.user.PixelSize = 6.5e-6;
pauliObj.parameters.user.EffectivePixelSize = pauliObj.parameters.      ...
    user.PixelSize / pauliObj.parameters.user.Magnification;
pauliObj.parameters.user.GperA = 7.8444;
pauliObj.parameters.user.dirtyHack = 1;

%% Set user constants for this atomic species (In this example: Li6)
pauliObj.constants.user.m = 9.9883e-27; %kg
pauliObj.constants.user.lambda = 6.709773382e-7; %m, D2 line
pauliObj.constants.user.gamma = 5.8724*1e6; %Hz
pauliObj.constants.user.vrecoil = 0.09886776; %m/s
pauliObj.constants.user.Isat = 25.4; %W/m²
pauliObj.constants.user.erecoil = (pauliObj.constants.hbar*2*pi* ...
    pauliObj.constants.user.lambda)^2/(2*pauliObj.constants.user.m); %J
pauliObj.constants.user.resonance_12 = 832.18; %G
pauliObj.constants.user.resonance_width_12 = -262.3; %G
pauliObj.constants.user.a_bg_12 = -1582*pauliObj.constants.a0; %m
pauliObj.constants.user.sigma = 3*pauliObj.constants.user.lambda^2/2/pi;

%% Internal Use, please dont modify
pauliObj.parameters.convertToDensityFunctionName = 'convertToDensity_HH_Li6_Doubleshot';
if nargout == 0
    pauliObj.saveConfig('Experiments\HH_Li6\Doubleshot.pauli');
end