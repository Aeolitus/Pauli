classdef PauliConst < handle
    % PauliConst   Class containing all natural constants
    %     This class contains all constants of nature and otherwise that
    %     are needed for operating 
    properties(Constant)
        a0 = 5.29177e-11;                   % Bohr radius
        hbar = 1.054571726e-34;             % Reduced Planck constant
        h = 2*pi*1.054571726e-34;
        U = 1.660538921e-27;                % Atomic mass
        kb = 1.3806488e-23;                 % Boltzmann constant
        c = 2.99792458e8;                   % Speed of light
        lightspeed = 2.99792458e8;          % Same
        g = 9.80665;                        % Gravitational acceleration
        e = 1.6021766e-19;                  % Elementary charge
    end
    properties
        user = struct();                    % User defined constants
    end
end