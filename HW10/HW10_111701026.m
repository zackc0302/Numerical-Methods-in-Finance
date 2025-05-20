clear; clc; close all;

% 基本參數設定
S0 = 50;        % 初始資產價格
K = 52;         % 履約價
r = 0.01;       % 無風險利率
T = 3/12;       % 到期時間（年）
vol = 0.22;     % 波動度
Step = 66;      % 模擬步數
SimuPath = 200:200:20000;

% 儲存結果
Price_naive = zeros(1, length(SimuPath));  % 無改善估值
LB_naive = zeros(1, length(SimuPath));
UB_naive = zeros(1, length(SimuPath));

Price_cv = zeros(1, length(SimuPath));     % 有改善估值（CV + QMC）
LB_cv = zeros(1, length(SimuPath));
UB_cv = zeros(1, length(SimuPath));

% 開始模擬
fprintf('Running simulation...\n');
for i = 1:length(SimuPath)
    Simu = SimuPath(i);

    % 無改善方法：單純算術平均蒙地卡羅（randn）
    [P_naive, lb1, ub1] = ArithmeticAsian_randn(S0, K, r, T, vol, Step, Simu);
    Price_naive(i) = P_naive;
    LB_naive(i) = lb1;
    UB_naive(i) = ub1;

    % 有改善方法：Control Variate + randn
    [P_cv, ci_cv] = AsianPut_mc_cv_sobol(S0, K, r, T, vol, Step, Simu);
    Price_cv(i) = P_cv;
    LB_cv(i) = ci_cv(1);
    UB_cv(i) = ci_cv(2);
end

% ======= 繪圖 =======
figure(1); clf;
hold on;

% 無改善（MC）
% p1 = plot(SimuPath, Price_naive, 'g-', 'LineWidth', 1.5);  % MC - Price
p2 = plot(SimuPath, LB_naive, 'g--', SimuPath, UB_naive, 'g--', 'LineWidth', 1.0);  % MC - CI

% 改善（CV + Sobol）
p3 = plot(SimuPath, Price_cv, 'b-', 'LineWidth', 1.5);  % CV+Sobol - Price
p4 = plot(SimuPath, LB_cv, 'b--', SimuPath, UB_cv, 'b--', 'LineWidth', 1.0);  % CV+Sobol - CI

legend([p2(1), p4(1), p3], {'MC - CI', 'CV+Sobol - CI', 'CV+Sobol - Price'},'Location','best');



xlabel('模擬次數');
ylabel('Put Price');
title('Arithmetic Asian Put: Monte Carlo vs. Control Variate + QMC');
grid on;
