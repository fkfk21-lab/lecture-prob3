classdef twolink
  properties (Constant)
   l1 = 0.5;
   a1 = 1.0;
   l2 = 0.25;
   a2 = 0.5;
   m1 = 10;
   m2 = 8;
   I1 = 5;
   I2 = 2.0;
   g = 9.8;
  end
  properties
    A_func
  end
  methods
    function obj = twolink()
      syms th1 th2 dth1 dth2
      x_sym = [th1; th2; dth1; dth2];
      f = obj.dae(x_sym, sym([0.0;0.0]));
      A_sym = simplify(jacobian(f, x_sym));
      obj.A_func = matlabFunction(A_sym, 'vars', [th1, th2, dth1, dth2]);
    end
    
    function ret = D(obj, q)
      phi1 = obj.m1*obj.l1^2 + obj.m2*obj.a1^2 + obj.I1;
      phi2 = obj.m2*obj.l2^2 + obj.I2;
      phi3 = obj.m2*obj.a1*obj.l2;
      c2 = cos(q(2));
      
      ret = [ phi1+phi2+2*phi3*c2 phi2+phi3*c2;
              phi2+phi3*c2  phi2];
    end
    
    function ret = h(obj, q, dq)
      phi3 = obj.m2*obj.a1*obj.l2;
      s2 = sin(q(2));
      
      H = [dq(2) dq(1)+dq(2);
           -dq(1) 0];
      v = [obj.m1*obj.l1*cos(q(1)) + obj.m2*(obj.a1*cos(q(1))+obj.l2*cos(q(1)+q(2)));
           obj.m2*obj.l2*cos(q(1)+q(2))];
      ret = -phi3*s2*H*dq + obj.g*v;
    end
    
    function ret = A(obj, x)
      th1 = x(1);
      th2 = x(2);
      dth1 = x(3);
      dth2 = x(4);
      ret = obj.A_func(th1, th2, dth1, dth2);
    end
    
    function ret = C(obj, x)
      ret = [obj.a1*cos(x(1))+obj.a2*cos(x(1)+x(2)) obj.a2*cos(x(1)+x(2)) 0 0];
    end
    
    function dxdt = dae(obj, x, u)
      q = x(1:2);
      dq = x(3:4);
      dxdt = [dq;obj.D(q)\(u-obj.h(q, dq))];
    end
    
    function dxdt = state_equation(obj, x, u, noise)
      dxdt = obj.dae(x, u) + mvnrnd(zeros([length(noise), 1]), noise, 1).';
    end
    
    function ret = obsfunc(obj, x)
      q = x(1:2);
      p2 = obj.p2(q);
      ret = p2(2);
    end
    
    function ret = observe(obj, x, noise)
      ret = obj.obsfunc(x) + mvnrnd(zeros([length(noise), 1]), noise, 1).';
    end
    
    function ret = p1(obj, q)
      ret = obj.a1*[cos(q(1));sin(q(1))];
    end
    
    function ret = p2(obj, q)
      ret = obj.p1(q) + obj.a2*[cos(q(1)+q(2));sin(q(1)+q(2))];
    end
  end
  
end