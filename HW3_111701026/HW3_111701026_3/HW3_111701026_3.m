x = [1 2 3]';
y = [4 5 6]';

X=cat(2, x, ones(3,1));

theta = (X' * X) \ (X' * y);

A = theta(1);
b = theta(2);

fprintf('y = %.4fx + %.4f\n', A, b);