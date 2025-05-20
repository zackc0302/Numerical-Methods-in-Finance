function Premium = Heston_Leastsquare(kappa, theta, v0, lambda, r, S0, K, rho, paths, steps, T, Option_type)
%   kappa       - 變異數均值回歸速度
%   theta       - 長期變異數水平
%   v0          - 初始變異數 V(0)
%   lambda      - 變異數的波動率 (vol of vol)
%   r           - 無風險利率
%   S0          - 初始資產價格 S(0)
%   K           - 履約價格
%   rho         - 資產價格與變異數的維納過程之間的相關係數
%   SimuPath    - 模擬路徑數量
%   Step        - 每個路徑的時間步數
%   T           - 選擇權到期時間 (年)
%   Option_type - 選擇權類型: 'p' (賣權) 或 'c' (買權)

% --- 第1部分: Heston模型路徑生成 ---
dt = T / steps; % 計算每個時間步長

SimSpace = zeros(paths, steps + 1); 
SimSpace(:, 1) = S0;       

Vt = ones(paths, 1) * v0; 

if 2 * kappa * theta < lambda^2
    warning('Feller條件 (2*kappa*theta >= lambda^2) 未被滿足。變異數路徑可能依賴於處理方式(如反射邊界)。');
end

R_matrix = [1, rho; rho, 1]; 

for s = 1:steps
    WT = mvnrnd([0, 0], R_matrix, paths) * sqrt(dt); 
    dW_S = WT(:, 1); 
    dW_V = WT(:, 2); 

    % 更新股價, 使用 max(Vt,0) 避免 sqrt 輸入負數 (儘管 Vt 理論上應非負)
    SimSpace(:, s+1) = SimSpace(:, s) .* exp((r - 0.5*Vt)*dt + sqrt(max(Vt,0)) .* dW_S); 
    
    % 更新變異數, 使用 max(Vt,0) 並對結果取絕對值 (反射邊界)
    Vt_next = Vt + kappa*(theta - Vt)*dt + lambda*sqrt(max(Vt,0)).*dW_V; 
    Vt = abs(Vt_next); 
end

% --- 第2部分: 最小二乘蒙地卡羅法 (LSMC) 評估美式選擇權 ---
Cash_Space = zeros(paths, steps + 1);

if Option_type == 'p' 
    Cash_Space(:, steps + 1) = max(K - SimSpace(:, steps + 1), 0);
elseif Option_type == 'c' 
    Cash_Space(:, steps + 1) = max(SimSpace(:, steps + 1) - K, 0);
else
    error('選擇權類型 (Option_type) 應為 "p" (賣權) 或 "c" (買權)');
end

% 反向遞迴計算
for t_col = steps:-1:2 
    S_at_t = SimSpace(:, t_col);

    if Option_type == 'p'
        ImmediateExerciseValue = max(K - S_at_t, 0);
    else % Option_type == 'c'
        ImmediateExerciseValue = max(S_at_t - K, 0);
    end

    InMoney_paths_indices = find(ImmediateExerciseValue > 0);
    EstimatedContinuationValue_all_paths = zeros(paths, 1);

    if ~isempty(InMoney_paths_indices)
        S_ITM = S_at_t(InMoney_paths_indices); 
        Y_regression = Cash_Space(InMoney_paths_indices, t_col+1) * exp(-r*dt);

        % 基底函數: 1, X, X^2, X^3 (三次多項式，共4個參數)
        X_reg_basis = [ones(length(S_ITM), 1), S_ITM, S_ITM.^2, S_ITM.^3];
        num_basis_params = size(X_reg_basis, 2); % 參數個數 (此處為4)
        
        ContinuationValue_for_ITM_paths_calc = zeros(length(S_ITM),1); % 初始化

        if size(S_ITM,1) >= num_basis_params 
            % 價內路徑數目足夠進行迴歸
            Beta = X_reg_basis \ Y_regression;
            ContinuationValue_for_ITM_paths_calc = X_reg_basis * Beta;
        else
            % 價內路徑數目不足以進行穩健的迴歸 (例如 SimuPath 太小)
            % 在此情況下，將預期持有價值直接設為觀察到的下一期折現價值 (Y_regression)
            % 這避免了因 Beta=0 (先前策略) 導致的預期持有價值為0，從而避免不必要的提前履約。
            ContinuationValue_for_ITM_paths_calc = Y_regression;
        end
        
        % 選擇權價值不能為負
        ContinuationValue_for_ITM_paths_calc(ContinuationValue_for_ITM_paths_calc < 0) = 0; 
        EstimatedContinuationValue_all_paths(InMoney_paths_indices) = ContinuationValue_for_ITM_paths_calc;
    end
    
    Value_if_held = Cash_Space(:, t_col+1) * exp(-r*dt);
    ShouldExercise = ImmediateExerciseValue > EstimatedContinuationValue_all_paths;
    
    current_t_option_value = Value_if_held;
    current_t_option_value(ShouldExercise) = ImmediateExerciseValue(ShouldExercise);
    
    Cash_Space(:, t_col) = current_t_option_value;
end

% --- 第3部分: 計算選擇權初始價格 (Premium) ---
OptionValue_at_dt_discounted_to_t0 = Cash_Space(:, 2) * exp(-r*dt);
Premium = mean(OptionValue_at_dt_discounted_to_t0);

% (可選) 計算標準誤
% SimuStdError = std(OptionValue_at_dt_discounted_to_t0) / sqrt(SimuPath);
% fprintf('選擇權價格: %f, 標準誤: %f\n', Premium, SimuStdError);

end