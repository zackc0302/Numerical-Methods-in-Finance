%% 參數設定
clear;clc;
S0=1;
K=1.1;
r=0.06;
T=1;
vol=0.45;
Option_type = 'p';
SimuPath=8;
Step=3;
dt=T/Step;

rng(20,'twister') 

SimSpace = zeros(SimuPath,Step+1);      %設定股價模擬空間
Cash_Space = zeros(SimuPath,Step+1);    %設定Cash Flow Table空間
SimSpace(:,1) = S0;                     %設定t0的股價為S0
dS_Space = zeros(SimuPath,Step);        %幾何布朗運動dS
RandSpace = randn(SimuPath,Step);       %幾何布朗運動模擬用隨機亂數

%首先模擬追蹤標的的資產變化，幾何布朗運動
for Smi=1:Step
    dS_Space(:,Smi) = r*dt.*SimSpace(:,Smi) + vol*sqrt(dt).*SimSpace(:,Smi).*RandSpace(:,Smi);
    SimSpace(:,Smi+1) = dS_Space(:,Smi) + SimSpace(:,Smi);
end
%% 計算到期日的Payoff

if Option_type == 'c'
    Cash_Space(:,end) = max( SimSpace(:,end) - K, 0)*exp(-r*dt);
elseif Option_type == 'p'
    Cash_Space(:,end) = max( K - SimSpace(:,end), 0)*exp(-r*dt);
else
    error('Option_type should be "c" or "p"')
end

%開始利用Linear Square計算是否提前履約與對應的現金流量
for t=Step:-1:2
    %找出t時點價內的Path Index
    if Option_type == 'c'
        InMoney = max( SimSpace(:,t) - K, 0);
    elseif Option_type == 'p'
        InMoney = max( K - SimSpace(:,t), 0);
    else
        error('Option_type should be "c" or "p"')
    end
    InMoney_index = find(InMoney);

    % 利用該Index找出迴歸需要的資料，X=t時點價內的股價，Y=下一期現金流折現
    S_in_t = SimSpace(InMoney_index,t);
    DisCF_dt = Cash_Space(InMoney_index,t+1)*exp(-r*dt);
    % 迴歸估計式：Y = β0 + β1*X + β2*X^2
    X = [ones(length(InMoney_index),1) S_in_t S_in_t.*S_in_t];
    % OLS估計 (X'X)^-1 * X'Y %% DisCF_dt= X*Beta  ---> Beta= X\DisCF_dt
    % Note that (X'X)^-1=  X^-1X'^-1
    Beta = (X'*X)\(X'*DisCF_dt);
    
    %計算t時點提早履約的價值與下一期條件期望價值
    CondExpValue = X*Beta; %Beta(1) + Beta(2).*S_in_t + Beta(3)*Beta(3).*S_in_t;
    if Option_type == 'c'
        EarlyExValue = S_in_t - K;
    elseif Option_type == 'p'
        EarlyExValue = K - S_in_t;
    else
        error('Option_type should be "c" or "p"')
    end
    
    Cash_Space(:,t) = Cash_Space(:,t+1)*exp(-r*dt);
    %計算確定要提早履約Path的index
    EarlyExind = EarlyExValue > CondExpValue;
    %依據index將提早履約的價值紀錄到Cash Flow Table
    Cash_Space(InMoney_index,t) = max(EarlyExind.*EarlyExValue,(1-EarlyExind).*Cash_Space(InMoney_index,t));
    %Cash Flow Tabl中確定提早履約的Path，其後價值歸零（因為已提早履約）
    %Chash_Space(nonzeros(EarlyExind.*InMoney_index),t+1:end) = 0;
end
%% 開始整理在不同時間點履約的Payoff，並依據履約時點折現到期初
% for Pai=1:SimuPath
%     %尋找某一Path，履約發生在哪個時間點
%     Exercise_ind = find(Chash_Space(Pai,:));   
%     %如果為空值代表到期日價外履約
%     if isempty(Exercise_ind)
%         Chash_Space(Pai,1) = 0;
%     else
%         %將履約時間點的價值依時間折現
%         Chash_Space(Pai,1) = Chash_Space(Pai,Exercise_ind) *exp(-r*dt*(Exercise_ind-1));
%     end
% end
Cash_Space(:,1)=Cash_Space(:,2)*exp(-r*dt);
Premium = mean(Cash_Space(:,1));
SimuStdError = std(Cash_Space(:,1));