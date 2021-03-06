classdef ukf < handle
  properties
    model;
    dt;
    x_est;
    P_est;
    Q;
    R;
    dim_state;
    dim_obs;
  end
  
  methods
    function obj = ukf(model, dt, x0, P0,Q, R)
      obj.model = model;
      obj.dt = dt;
      obj.x_est = x0;
      obj.P_est = P0;
      obj.Q = Q;
      obj.R = R;
      obj.dim_state = length(x0);
      obj.dim_obs = length(R);
    end
    
    function [Chi, W] = generate_sigma_points(obj, x, P)
      n = length(x);
      kappa = 3-n;
      Chi = repmat(x,1,2*n+1); %Τ
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
      % Tv_(Sigma Points)ΜΆ¬
      xa = [obj.x_est; zeros([obj.dim_state], 1)];
      Pa = blkdiag(obj.P_est, obj.Q);
      [Chi, W] = obj.generate_sigma_points(xa, Pa);
      % \ͺ½ΟπvZ
      Chi_pred = Chi(1:obj.dim_state, :);
      x_pred = zeros(size(obj.x_est));
      for i = 1:length(Chi)
        noise = diag(Chi(obj.dim_state+1:obj.dim_state*2, i));
        chi_pred = Chi(1:obj.dim_state,i) + ...
                   obj.model.state_equation(Chi(1:obj.dim_state,i), input, noise*noise)*obj.dt;
        Chi_pred(1:obj.dim_state, i) = chi_pred;
        w = W(:,i);
        x_pred = x_pred + w * chi_pred;
      end
      
      % \ͺͺUπvZ
      P_pred = zeros(size(obj.P_est));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        P_pred = P_pred + w * (chi_pred-x_pred)*(chi_pred-x_pred).';
      end
      
      % Sigma PointsπΟͺΦΕJΪ³ΉA\ͺΟͺl,\ͺͺUπί
      Gamma = repmat(obs, 1, height(Chi));
      y_pred = zeros(size(obs));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        gamma = obj.model.observe(chi_pred, 0);
        y_pred = y_pred + w*gamma;
        Gamma(:, i) = gamma;
      end
      
      % \ͺͺUπvZ
      Pyy_pred = zeros(size(obs*obs.'));
      Pxy_pred = zeros(size(x_pred*obs'));
      for i = 1:length(Chi)
        chi_pred = Chi_pred(:, i);
        w = W(:,i);
        gamma = Gamma(:,i);
        Pyy_pred = Pyy_pred + w*(gamma - y_pred)*(gamma - y_pred).';
        Pxy_pred = Pxy_pred + w*(chi_pred - x_pred)*(gamma - y_pred).';
      end
      
      % Cmx[VΜ\ͺ€ͺUπvZ
      v = obs - y_pred;
      Pvv_pred = obj.R + Pyy_pred;
      
      % J}QCπvZ
      Gain = Pxy_pred / Pvv_pred;
      
      % θl,\ͺλ·€ͺUπXV
      x_est = x_pred + Gain*v;
      P_est = P_pred - Gain*Pvv_pred*Gain.';
      
      % NXΜΟΰXV
      obj.x_est = x_est;
      obj.P_est = P_est;
    end
  end
end

