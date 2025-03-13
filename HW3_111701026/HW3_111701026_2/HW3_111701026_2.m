IntTable = xlsread('Read_InterestRate.xlsx');

initial_amount = 1;

a1  = initial_amount * (1 + IntTable(1,1)/12); % 固定一個月  
a2  = initial_amount * (1 + IntTable(2,1)/12); % 機動一個月  
a3  = initial_amount * (1 + IntTable(1,2)/4);  % 固定三個月 
a4  = initial_amount * (1 + IntTable(1,3)/2);  % 固定六個月
a5 = initial_amount * (1 + IntTable(1,5)/2) * (1 + IntTable(1,5)/2); % 一年定存半年複習

% **計算 Spread (固定利率 - 機動利率)**
spread = IntTable(1, :) - IntTable(2, :); 
results = [a1, a2, a3, a4, a5, spread]; 

writematrix(results, 'HW3_111701026_result.xlsx');

