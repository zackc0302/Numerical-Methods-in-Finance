function [BondP,Yield] = Yield(F,coupon,T,n,LB,UB,MarketP)
    threshold = 1e-6;
    Deviation = inf;
    iter = 0;
    
    % fprintf('Iter\tYield\t\tBondP\t\tDeviation\n');
    % fprintf('----------------------------------------------\n');

    while Deviation > threshold
        iter = iter + 1;
        Yield = (LB + UB) / 2;
        [BondP, Dev] = Bond(F, coupon, Yield, T, n, MarketP);
        Deviation = abs(Dev);
        
        % 顯示目前這一步的資訊
        % fprintf('%d\t%.6f\t%.4f\t%.6f\n', iter, Yield, BondP, Deviation);

        if Dev > 0
            LB = Yield;
        else
            UB = Yield;
        end

        if abs(UB - LB) < threshold
            break;
        end
    end
end

function [P, Dev] = Bond(F, coupon, Yield, T, n, MarketP)
    r = Yield / n;
    N = T * n;
    C = (coupon * F) / n;  % 修正：每期息票金額

    P = 0;
    for i = 1:N
        P = P + C / (1 + r)^i;
    end
    P = P + F / (1 + r)^N;
    Dev = P - MarketP;
end