% 練習題：找出利率 r，使得債券價格等於市場價格
% 題目敘述：
% 一張面額為 $1000 的零息債券（Zero-Coupon Bond），
% 將在 T = 3 年後到期。你觀察到它目前的市場價格為 $850，
% 請你估算市場對應的年化利率 r（即 Yield to Maturity, YTM是多少？
FV = 1000;
T = 3;
P_market = 850;
LB = 0.01;
UB = 0.2;

obj_fun = @(r) bonddiff(r, FV, T, P_market);

r_estimated = fzero(obj_fun, [LB, UB]);

fprintf("估計利率為: %.4f\n", r_estimated);  

function diff = bonddiff(r, FV, T, P_market)
    price = FV / (1 + r)^T;
    diff = price - P_market;
end
