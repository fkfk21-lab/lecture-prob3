classdef ukf < handle
  properties
    model;
    dt;
    x_est;
    P_est;
    R;
    dim_state;
    dim_obs;
  end
  
  methods
    function obj = ukf(model, dt, x0, P0, R)
      obj.model = model;
      obj.dt = dt;
      obj.x_est = x0;
      obj.P_est = P0;
      obj.R = R;
      obj.dim_state = length(x0);
      obj.dim_obs = length(R);
    end
    
    function [Chi, W] = generate_sigma_points(obj, x, P)
      n = length(x);
      kappa = 3-n;
      Chi = repmat(x,1,2*n+1); %ƒÔ
      W = repmat(kappa / (n+kappa), 1, 2*n+1);
      sqrtP = chol(P);
      for i = 1:n
        Chi(:, 2*i) = x + sqrt(n+kappa)*sqrtP(:,i);
        Chi(:, 2*i+1) = x - sqrt(n+kappa)*sqrtP(:,i);
        w = 1/(2*(n+kappa));
        W(:, 2*i) = w;
        W(:, 2*i+1) = w;
      end
    end
    
    function [x_est, P_est] = estimate(obj, obs, input)      
      % ƒTƒ“ƒvƒ‹“_(Sigma Points)‚Ì¶¬
      [Chi, W] = obj.generate_sigma_points(obj.x_est, obj.P_est);
      display(Chi)
      % —\‘ª•½‹Ï‚ðŒvŽZ
      Chi_pred = Chi;
      x_pred = zeros(size(obj.x_est));
      for i = 1:length(Chi)
        chi_pred = Chi(:,i) + obj.model.dae(Chi(:,i), input)*obj.dt;
        Chi_pred(:, i) = chi_pred;
        w = W(:,i);
        x_pred = x_pred + w * chi_pred;
      end
      
      % —\‘ª•ªŽU‚ðŒvŽZ
      P_pred = zeros(size(obj.P_est));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        P_pred = P_pred + w * (chi_pred-x_pred)*(chi_pred-x_pred).';
      end
      
      % Sigma Points‚ðŠÏ‘ªŠÖ”‚Å‘JˆÚ‚³‚¹A—\‘ªŠÏ‘ª’l,—\‘ª•ªŽU‚ð‹ßŽ—
      Gamma = repmat(obs, 1, height(Chi));
      y_pred = zeros(size(obs));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        gamma = obj.model.observe(chi_pred, 0);
        y_pred = y_pred + w*gamma;
        Gamma(:, i) = gamma;
      end
      
      % —\‘ª•ªŽU‚ðŒvŽZ
      Pyy_pred = zeros(size(obs*obs.'));
      Pxy_pred = zeros(size(x_pred*obs'));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        gamma = Gamma(:,i);
        Pyy_pred = Pyy_pred + w*(gamma - y_pred)*(gamma - y_pred).';
        Pxy_pred = Pxy_pred + w*(chi_pred - x_pred)*(gamma - y_pred).';
      end
      
      % ƒCƒmƒx[ƒVƒ‡ƒ“‚Ì—\‘ª‹¤•ªŽU‚ðŒvŽZ
      v = obs - y_pred;
      Pvv_pred = obj.R + Pyy_pred;
      
      % ƒJƒ‹ƒ}ƒ“ƒQƒCƒ“‚ðŒvŽZ
      Gain = Pxy_pred / Pvv_pred;
      
      % „’è’l,—\‘ªŒë·‹¤•ªŽU‚ðXV
      x_est = x_pred + Gain*v;
      P_est = P_pred - Gain*Pvv_pred*Gain.';
      
      % ƒNƒ‰ƒX‚Ì•Ï”‚àXV
      obj.x_est = x_est;
      obj.P_est = P_est;
    end
  end
end

