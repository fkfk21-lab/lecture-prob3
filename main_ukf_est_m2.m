clear;
Ts = 0.01;
t = 0:Ts:10;

x0 = [0.0; pi/4; 0; 0; 6.0];
P0 = diag([0.5, 0.5, 0.1, 0.1 1.0]);
obs_noise_std = 0.01;
Q = diag([0.001, 0.001, 0.01, 0.01, 1.0e-5]);
R = obs_noise_std^2;
model_true = twolink(Ts);
model = twolink_est_m2(x0(5),Ts);
filter = ukf(model, Ts, x0, P0, Q, R);
u = [0; 0];

% storage for logging
data.x_true = zeros(4, length(t));
data.x_est = zeros(5, length(t));
data.obs = zeros(1, length(t));

% simulation
x_true = x0(1:4);
for k = 1:length(t)
  x_true = x_true + model_true.dae(x_true,u)*Ts;
  obs = model_true.observe(x_true, R);
  
  [x_est, P_est] = filter.estimate(obs, u);

  data.x_true(:, k) = x_true;
  data.x_est(:, k) = x_est;
  data.obs(:, k) = obs;
end