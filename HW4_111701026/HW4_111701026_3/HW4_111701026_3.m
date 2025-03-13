% 讀取 Excel 檔案
[data, text] = xlsread("Read.xls");

% 讀取欄位數據
date = text(3:end,1);
taiwan_idx = data(:,1);
elec_idx = data(:,2);
fin_idx = data(:,3);

% 找出符合題目需求的index
idx = (taiwan_idx > 5000) & (elec_idx > 260);

% 取出符合條件的數據
dates = date(idx);
taiwan_index = taiwan_idx(idx);
electronic_index = elec_idx(idx);
finance_index = fin_idx(idx);

% 顯示結果
disp(table(dates, taiwan_index, electronic_index, finance_index));
