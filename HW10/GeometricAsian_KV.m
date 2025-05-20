function P = GeometricAsian_KV (S0, K, T, r, sigma, type)
%Base Kemma and Vorst (1990)
b = 0.5*(r-(sigma^2/6));
sigma_A = sigma/sqrt(3);
d1 = (log(S0/K)+b+0.5*sigma_A^2*T) /  (sigma_A*sqrt(T));
d2 = d1 - sigma_A*sqrt(T);

switch type
    case 'c'
        P = S0*exp((b-r)*T)*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
    case 'p'
        P  = K*exp(-r*T)*normcdf(-d2) - S0*exp((b-r)*T)*normcdf(-d1);
    otherwise
        disp('Please key in "p" or "c"');
end
