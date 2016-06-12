function [ UOut, VOut ] = getIzhikLineofConv(a, b, InitPoint, onemsbyTstep, Threshold)
%GETIZHIKLINEOFCONV Returns the Line of Convergence for a given Izhikevich
%Neuron
%   
%   [U,V] = getIzhikLineofConv(a, b, InitPYoint)
%   
% Starts at InitPoint (which is a vector of length 2 [UInit, VInit),
% simulates using a, b until it reached equilibrium or spike. If it
% reaches spike then [], [] is returned. Else the set of X, Y of the
% points traversed during simulation is returned.

if nargin() < 5
    Threshold = 0.0001;
end

U = InitPoint(1);
V = InitPoint(2);

UNow = U;
VNow = V;
Movement = inf;
while Movement > Threshold/onemsbyTstep && VNow < 30.0
    VNext = VNow + (0.04*VNow^2 + 5*VNow + 140 - UNow)/onemsbyTstep;
    UNext = UNow + a*(b*VNow-UNow)/onemsbyTstep;
    if VNext < -100
        VNext = -100;
    end
    V(end+1,1) = VNext;
    U(end+1,1) = UNext;
    Movement = sqrt((VNext-VNow)^2 + (UNext-UNow)^2);
    VNow = VNext;
    UNow = UNext;
end

if VNow > 30.0
    V(end, 1) = 30.0;
end

UOut = U;
VOut = V;
end