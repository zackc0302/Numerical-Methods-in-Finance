clear; clc;
F = 1000;           % 票面價值（本金）
cr = 0.06;          % 年票面利率（例如 6%）
T = 2;              % 債券存續年限（年）
n = 4;              % 每年付息期數（例如季付息就是4）
MarketP = 1018;     % 市場價格

Deviation = 10;            % 初始差距
threshold = 0.001;         % 接受門檻
a = 0.01; b = 0.2;          % YTM 二分法上下限（年化殖利率）

while Deviation > threshold
    r = (a + b) / 2;                 % 中間殖利率（年化）
    [P, Dev] = Bond(F, cr, r, T, n, MarketP);
    Deviation = abs(Dev);           % 計算與市場價格差異

    if Dev > 0
        b = r;  % 計算價太高 → 殖利率太低 → 提高殖利率
    else
        a = r;  % 計算價太低 → 殖利率太高 → 降低殖利率
    end
end

fprintf('殖利率 (YTM): %.4f (年化)\n', r);
fprintf('債券價格: %.2f\n', P);


function [P, Dev] = Bond(F, cr, r, T, n, MarketP)
    % F: 票面本金
    % cr: 年票面利率
    % r: 年殖利率（嘗試值）
    % T: 債券年限
    % n: 每年期數（季：4，月：12）
    % MarketP: 市場價格

    dt = 1 / n;                    % 單位期長度
    N = T * n;                     % 總期數
    C = (cr * F) / n;              % 每期付息金額
    r_per_period = r / n;         % 每期殖利率

    P = 0;
    for i = 1:N-1
        P = P + C / (1 + r_per_period)^i;
    end
    P = P + (C + F) / (1 + r_per_period)^N;  % 最後一期含本金

    Dev = P - MarketP;            % 與市場價格差距
end
