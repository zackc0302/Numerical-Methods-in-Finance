x=[2 3 4;3 4 5;4 5 6];
writematrix(x,'b.xls'); 
data=readmatrix('Read.xls', 'Sheet', 'Sheet1');
writematrix(data,'c.xls');