function res = strdupe(s,n)
if n == 1
    res = s;
else
    res = [strdupe(s,n-1) s];
end
end

