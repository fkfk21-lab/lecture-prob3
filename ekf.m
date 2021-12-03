classdef ekf < handle
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
    function obj = ekf(model, dt, x0, P0, Q, R)
      obj.model = model;
      obj.dt = dt;
      obj.x_est = x0;
      obj.P_est = P0;
      obj.Q = Q;
      obj.R = R;
      obj.dim_state = length(x0);
      obj.dim_obs = length(R);
    end
    
    function [x_est, P_est] = estimate(obj, obs, input)
      x_pred = obj.x_est + obj.model.dae(obj.x_est, input)*obj.dt;
      y_pred = obj.model.observe(x_pred, obj.R);
      
      A = obj.model.A(obj.x_est);
      C = obj.model.C(obj.x_est);
      P = obj.P_est;
      P_pred = A*P*A.' + obj.Q;
      K = P_pred*C.' / (C*P_pred*C.' +obj.R);
      
      x_est = x_pred + K*(obs - y_pred);
      P_est = (eye(4) - K*C)*P_pred;

      obj.x_est = x_est;
      obj.P_est = P_est;
    end
  end
end

