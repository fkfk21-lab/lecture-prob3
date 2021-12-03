% data x
figure;
names = ["$\theta_1$", "$\theta_2$", "$\dot{\theta_1}$", "$\dot{\theta_2}$"];
for i=1:4
  subplot(2,2,i);
  hold on;
  plot(t, data.x_true(i,:));
  plot(t, data.x_est(i,:));
  formatSpec = 'state: %s';
  title(sprintf(formatSpec, names(i)), 'Interpreter', 'latex');
  legend("true","est");
end

if height(data.x_est) >= 5
  figure;
  hold on;
  plot(t, repmat(model_true.m2, length(t), 1));
  plot(t, data.x_est(5,:));
  title("m2");
  legend("true", "est");
end

% data y
figure;
plot(t, data.obs);
title("observed value (y)");
legend("y");