% roots函數可解決多項式的根，使其為0
p=[1 2 1];
roots(p)

% fzero用在一元非線性函數求根
% 求x=多少時，exp(x)+cos(x)=0
f=@(x) exp(x)+cos(x);
fzero(f, 0) % 第一個參數(f是函數名稱；0是希望的值或猜測區間)

