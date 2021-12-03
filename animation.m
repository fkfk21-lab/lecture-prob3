set(0, 'DefaultLineLineWidth', 2);

save_video = false;
filename = "test.mp4";
close all;
f = figure;
hold on
axis equal
p1 = model.p1(x0(1:2));
p2 = model.p2(x0(1:2));
arm = plot([0, p1(1), p2(1)], [0, p1(2), p2(2)]);
arm_est = plot([0, p1(1), p2(1)], [0, p1(2), p2(2)]);
xlim([-1.5, 1.5]);
ylim([-1.5, 1.5]);

formatSpec = 'time: %.4f';
title_handle = title(sprintf(formatSpec, 0.0));


rate = 1/Ts;
%v_period = 1/rate*playratio;
set(0, 'DefaultLineLineWidth', 2);

pause(1)

if save_video
    disp('Saving movie')
    v=VideoWriter(filename, 'MPEG-4');
    v.FrameRate = rate;
    open(v)
    mov = getframe(f);
    writeVideo(v,mov);
end

for k = 1:length(t)
  x = data.x_true(:, k);
  q = x(1:2);
  p1 = model.p1(q);
  p2 = model.p2(q);
  arm.XData = [0, p1(1), p2(1)];
  arm.YData = [0, p1(2), p2(2)];
  title_handle.String = sprintf(formatSpec, t(k));
  pause(Ts);
  if save_video
    mov = getframe(f);
    writeVideo(v, mov);
  end
end

if save_video
  close(v);
  disp('Finished');
end


set(0, 'DefaultLineLineWidth', 1);


