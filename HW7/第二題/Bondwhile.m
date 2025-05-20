r=input('輸入債券殖利率: ');
n=input('輸入期數: ');
c=input('輸入票面利率: ');
F=input('輸入本金: ');
Value=0;
i=1
while i<=n
    Value=Value+c*F/((1+r)^i);
    if i==n
        Value=Value+F/((1+r)^i);
    end
    i=i+1
end
disp(Value);