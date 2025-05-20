function [Price_CV, CI_CV] = AsianPut_mc_cv_sobol(S0,K,r,T,vol,Step,Simu)
    dt= T/Step;
    R = exp(-r*T);
    MC_arith = zeros(1,Simu);
    MC_geo = zeros(1,Simu);

    % 產生 Sobol 序列並轉換為常態分布
    p = sobolset(Step, 'Skip', 1e3, 'Leap', 1e2);
    sobol_points = net(p, Simu);
    RandSpace = norminv(sobol_points, 0, 1);  % 轉成標準常態

    for j = 1:Simu
        Z = (r - vol^2/2)*dt + vol*sqrt(dt)*RandSpace(j,:);
        S = exp(cumsum([log(S0), Z], 2));
        A = mean(S);   % 算術平均
        G = geomean(S); % 幾何平均
        MC_arith(j) = max(K - A, 0);  % 賣權 payoff
        MC_geo(j)   = max(K - G, 0);  % 賣權 payoff
    end

    covar = cov(MC_arith, MC_geo);
    c = covar(1,2)/covar(2,2); % Optimal control variate coefficient
    GeoPut = GeometricAsian_KV(S0,K,T,r,vol,'p'); % 幾何平均封閉解

    CV = R * MC_arith - c * (R * MC_geo - GeoPut);
    Price_CV = mean(CV);
    std_err = std(CV)/sqrt(Simu);
    z = norminv(0.975);
    CI_CV = [Price_CV - z*std_err, Price_CV + z*std_err];
end
