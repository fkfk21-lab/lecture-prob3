syms th1 th2 dth1 dth2
model = twolink;
x_sym = [th1; th2; dth1; dth2];
f = model.dae(x_sym, sym([0.0;0.0]));
A_sym = simplify(jacobian(f, x_sym));