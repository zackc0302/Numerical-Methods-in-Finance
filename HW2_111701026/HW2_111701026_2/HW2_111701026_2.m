data1 = readmatrix('Read.xls', 'Range', 'B3:B103');
data2 = readmatrix('Read.xls', 'Range', 'C3:C103');
data3 = readmatrix('Read.xls', 'Range', 'D3:D103');
col_max1 = max(data1, [], 1);
col_min1 = min(data1, [], 1);
col_avg1 = mean(data1,1);
col_sum1 = sum(data1,1);

col_max2 = max(data2, [], 1);
col_min2 = min(data2, [], 1);
col_avg2 = mean(data2,1);
col_sum2 = sum(data2,1);

col_max3 = max(data3, [], 1);
col_min3 = min(data3, [], 1);
col_avg3 = mean(data3,1);
col_sum3 = sum(data3,1);

disp('台指最大:'),disp(col_max1);
disp('台指最小:'),disp(col_min1);
disp('台指平均:'),disp(col_avg1);
disp('台指總和:'),disp(col_sum1);
disp('電子指最大:'),disp(col_max2);
disp('電子指最小:'),disp(col_min2);
disp('電子指平均:'),disp(col_avg2);
disp('電子指總和:'),disp(col_sum2);
disp('金融指最大:'),disp(col_max3);
disp('金融指最小:'),disp(col_min3);
disp('金融指平均:'),disp(col_avg3);
disp('金融指總和:'),disp(col_sum3);