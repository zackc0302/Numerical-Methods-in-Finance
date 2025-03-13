% 讀取 Excel 文件，忽略前兩行
[data, txt, raw] = xlsread('Read.xls');

% 假設前兩行是標題或無效數據，從第三行開始取數據
tw = data(:,1);      % 台指
elec = data(:,2);    % 電子指數
fin = data(:,3);     % 金融指數

% 構造回歸矩陣，加入截距項 (常數項)
mix = [ones(size(elec)), elec, fin];  

% 計算最小平方法回歸係數
C = mix \ tw;

% 使用 regress() 驗證
[b, bint, r, rint, stats] = regress(tw, mix);
% b: 迴歸係數
% bint: 迴歸係數的信賴區間
% r: 殘差(真實質-預測值)
% rint: 殘差的信賴區間
% stats: 回歸統計數據，包括R^2值、F值、p-value、標準誤差


% 顯示結果
disp('回歸係數:');
disp(C);

disp('回歸統計數據:');
disp(stats);
