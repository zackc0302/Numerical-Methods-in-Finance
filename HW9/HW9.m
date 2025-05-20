S0 = 50;
K = 48;
r = 0.01;
T = 1/12;
vol = 0.22;
SimuPath = 2000;

R = exp(-r * T); 
rng(15, 'twister'); 

MC_simulation = zeros(2, SimuPath);
S_Maturity = zeros(1, SimuPath);
tic
for j = 1:SimuPath
    % 一期直接算 S_T
    ST = S0 * exp((r - 0.5 * vol^2) * T + vol * sqrt(T) * randn(1,1));
    
    % 歐式買權與賣權 payoff
    MC_simulation(1, j) = max(ST - K, 0);
    MC_simulation(2, j) = max(K - ST, 0);
    
    % 記錄到期價格
    S_Maturity(1, j) = ST;
end
toc
% 計算折現後平均價格
CallPrice = R * mean(MC_simulation(1, :));
PutPrice = R * mean(MC_simulation(2, :));

% 檢查 Put-Call Parity
PC_parity_left = CallPrice - PutPrice;
PC_parity_right = R * mean(S_Maturity) - K * R;

verify = abs(PC_parity_left - PC_parity_right);

if verify < 1e-6
    disp('Put Call Parity holds.');
else
    disp('Put Call Parity does not hold.');
end
