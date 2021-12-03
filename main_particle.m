clear;
Ts = 0.01;
t = 0:Ts:10;

x0 = [0.0; pi/4; 0; 0];
P0 = diag([0.5, 0.5, 0.1, 0.1]);
noise_std = 0.01;
R = noise_std^2;
model = twolink(noise_std);
filter = particle_filter(model, Ts, x0, P0, R, N);
u = [0; 0];

% storage for logging
data.x_true = zeros(4, length(t));
data.x_est = data.x_true;
data.obs = zeros(1, length(t));

% simulation
x_true = x0;
obs = x0;
for k = 1:length(t)
  x_true = x_true + model.dae(x_true,u)*Ts;
  obs = model.observe(x_true);
  
  [x_est, P_est] = filter.estimate(obs, u);

  data.x_true(:, k) = x_true;
  data.x_est(:, k) = x_est;
  data.obs(:, k) = obs;
end