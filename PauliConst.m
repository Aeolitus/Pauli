classdef PauliConst < handle
    % PauliConst   Class containing all natural constants
    %     This class contains all constants of nature and otherwise that
    %     are needed for operating 
    properties(Constant)
        a0 = 5.29177e-11;                   % Bohr radius
        hbar = 1.054571726e-34;             % Reduced Planck constant
        U = 1.660538921e-27;                % Atomic mass
        kb = 1.3806488e-23;                 % Boltzmann constant
        c = 2.99792458e8;                   % Speed of light
        lightspeed = 2.99792458e8;          % Same
        g = 9.80665;                        % Gravitational acceleration
        e = 1.6021766e-19;                  % Elementary charge
    end
%     methods
%         function obj = PauliConst()
%             obj.m.li6 = 9.9883e-27;
%             obj.m.li7 = 1.1650349e-26;
%             obj.m.k39 = 6.470076e-26;
%             obj.m.k40 = 6.6362e-26;
%             obj.m.rb83 = 1.3768378e-25;
%             obj.m.rb85 = 1.4099934e-25;
%             obj.m.rb87 = 1.4431609e-25;
%             
%             obj.d2.li6 = 6.709773382e+17;
%             obj.d1.li6 = 6.709924206e+17;
%         end
%     end
end