classdef particle_filter < handle
  properties
    model;
    dt;
    x_est;
    P_est;
    particles;
    w;
    R;
    dim_state;
    dim_obs;
    N;
  end
  
  methods
    function obj = particle_filter(model, dt, x0, P0, R, N)
      obj.model = model;
      obj.dt = dt;
      obj.x_est = x0;
      obj.P_est = P0;
      obj.particles = mvnrnd(x0, P0, N)';
      obj.w = mvnrnd(0, )
      obj.R = R;
      obj.dim_state = length(x0);
      obj.dim_obs = length(R);
      obj.N = N;
    end
    
    function ret = logpdf(X, cov)
      det_cov = det(cov);
      inv_cov = inv(cov);
      [k, ~] = size(cov);
      coefs = [];
      for x = X
        coefs(end+1) = dot(dot(x, inv_cov), x');
      end
      ret = -k*log(2*pi)/2 -log(det_cov)/2 -coefs/2;
    end
    
    function [x_est, P_est] = estimate(obj, obs, input)
      
      % パーティクルを遷移
      particles_est = obj.particles;
      obs_pars = zeros(length(obs), obj.N);
      for i = 1:obj.N
        xi = obj.particles(:,i);
        particles_est(:,i) = xi + obj.model.dae(xi, input)*obj.dt;
        obs_pars(:,i) = obj.model.obsfunc(particles_est(:,i));
      end
      
      % 重み係数の更新
      Y = repmat(obs, 1, obj.N);
      loglh = logpdf(abs(Y-obs_pars), obj.R);
      
    end
  end
end

