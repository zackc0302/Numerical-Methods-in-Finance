function [IV, verify] = implied_vol(S, Z, r, T, LB, UB, MarketP, Option)
    % 使用 fzero 搜尋隱含波動率
    obj_fun = @(sigma) option_diff(sigma, S, Z, r, T, MarketP, Option);
    IV = fzero(obj_fun, [LB, UB]);

    % 計算對應的 BS 價格並比對
    [BSCall, BSPut] = BSoption(S, Z, r, T, IV);
    if Option == "call"
        BSPrice = BSCall;
    else
        BSPrice = BSPut;
    end

    if abs(BSPrice - MarketP) < 1e-4
        verify = 'these two price are same.';
    else
        verify = 'they are different.';
    end

    % 嵌套函數：計算 Black-Scholes 選擇權價格
    function [BSCall, BSPut] = BSoption(S, Z, r, T, Sigma)
        d1 = (log(S / Z) + (r + 0.5 * Sigma^2) * T) / (Sigma * sqrt(T));
        d2 = d1 - Sigma * sqrt(T);
        BSCall = S * normcdf(d1) - Z * exp(-r * T) * normcdf(d2);
        BSPut = Z * exp(-r * T) * normcdf(-d2) - S * normcdf(-d1);
    end

    % 嵌套函數：目標函數
    function diff = option_diff(sigma, S, Z, r, T, MarketP, Option)
        [BSCall, BSPut] = BSoption(S, Z, r, T, sigma);
        if Option == "call"
            diff = BSCall - MarketP;
        else
            diff = BSPut - MarketP;
        end
    end
end
