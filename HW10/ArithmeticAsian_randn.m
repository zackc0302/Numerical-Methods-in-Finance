function [price, lb, ub] = ArithmeticAsian_randn(S0,K,r,T,vol,Step,Simu)
    R = exp(-r*T); dt = T/Step;
    Payoff = zeros(1, Simu);
    RandSpace = randn(Simu, Step);

    for j = 1:Simu
        Z = (r - vol^2/2)*dt + vol*sqrt(dt)*RandSpace(j,:);
        S = exp(cumsum([log(S0), Z], 2));
        A = mean(S);  % 算術平均
        Payoff(j) = max(K - A, 0);
    end

    price = R * mean(Payoff);
    std_err = std(Payoff) / sqrt(Simu);
    z = norminv(0.975);
    lb = price - z * std_err;
    ub = price + z * std_err;
end
