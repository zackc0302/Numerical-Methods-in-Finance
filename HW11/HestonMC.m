clear;clc;close;
kappa = 4;          % Mean reversion speed for the variance
theta = 0.02;       % Long-term variance level
v0 =  0.02;         % Asset price variance at time 0
lambda = 0.3;       % Volatility of the variance
r = 0.02;           % Risk-free rate
S0 = 100;           % Asset price at time 0
rho = 0.9;          % Correlation between the Wiener processes W^S_t and W^V_t
paths = 1000;       % Simulae Path. 
steps = 252;        % Simulation Step
T = 1;              % Period
if 2*kappa*theta<lambda^2
    error('The Feller condition falls');
end
[P1, sigs1] = gen_Heston_path(S0, T, r, kappa, theta, v0, rho, lambda, steps, paths);

figure
plot(P1')

function [P, sigs] = gen_Heston_path(S0, T, r, kappa, theta, v0, rho, lambda, steps, NPaths)

dt = T/steps;
n = [NPaths, steps];
P = zeros(n);    % 存放資產價格
sigs = zeros(n); % 存放波動率

St = S0;
Vt = v0;
R = [1,rho;rho,1];  %Covariances of multivariate normal distributions
    for i = 1:steps
        WT = mvnrnd([0,0], R, NPaths) * sqrt(dt);
        St = St.*(exp((r-0.5*Vt)*dt + sqrt(Vt).*WT(:,1)));
        Vt = abs(Vt + kappa*(theta-Vt)*dt + lambda*sqrt(Vt).*WT(:,2));
        P(:,i) = St;
        sigs(:,i) = Vt;
    end

end
