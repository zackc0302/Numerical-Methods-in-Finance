function [P, Value, MD] = MacaulayDuration(r, n, c, F)
    % r: 利率
    % n: 年數
    % c: 票面利率（如 5% 請輸入 0.05）
    % F: 面額（如 1000）

    C = c * F;  % 每期固定付息金額
    P = 0;

    % Step 1: 計算債券價格 P（折現所有現金流）
    for i = 1:n
        P = P + C / (1 + r)^i;
    end
    P = P + F / (1 + r)^n;  % 本金在最後一期支付

    % Step 2: 計算加權現金流總和（Macaulay Duration 的分子）
    Value = 0;
    for i = 1:n
        Value = Value + i * C / (1 + r)^i;
    end
    Value = Value + n * F / (1 + r)^n;

    % Step 3: Macaulay Duration
    MD = Value / P;
end
