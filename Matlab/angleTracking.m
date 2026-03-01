clear; close all; clc;
rng('shuffle');
c = 343; %sound
Fs = 100;
T = 10;
bound = 100;

thermal_noise_sigma = 50e-6;
timing_window = 100e-6;

mic_pos = [
    [0 0]
    [1 1]
    [1 -1]
    [-1 1]
    [-1 -1]
];
num_mics = size(mic_pos, 1);
ref_index = 1;

t = 0:1/Fs:T;

pos_points_x = bound*(2*rand(1,T+1)-1);
pos_x = spline(0:T, pos_points_x, t);
pos_points_y = bound*(2*rand(1,T+1)-1);
pos_y = spline(0:T, pos_points_y, t);

% distances(t, mic_index)
distances = sqrt((mic_pos(:,1) - pos_x).^2 + (mic_pos(:,2) - pos_y).^2)';
time_to_mic = distances/c;
jitter = thermal_noise_sigma*randn(length(t), num_mics) + timing_window*(2*rand(length(t), num_mics)-1);
time_to_mic_noisy = time_to_mic + jitter;

tau = time_to_mic_noisy - time_to_mic_noisy(:, ref_index);

A = mic_pos(2:end,:) - mic_pos(ref_index,:);
b = -c * tau(:,2:end)';

u = (A'*A)\(A'*b);
u = u./vecnorm(u);

theta = atan2(u(2, :),u(1, :));

delay_samples = round(time_to_mic(:, ref_index) * Fs); % in samples

theta_delayed = zeros(size(theta));

for k = 1:length(theta)
    idx = k - delay_samples(k);
    if idx < 1
        theta_delayed(k) = NaN; % signal hasn't arrived yet
    else
        theta_delayed(k) = theta(idx);
    end
end

real_theta = atan2(pos_y, pos_x);

figure;
subplot(2,1,1);
plot(t, rad2deg(theta_delayed));
hold on;
plot(t, rad2deg(real_theta));
title('Measured vs real direction');
ylabel('Angle (deg)');
ylim([-180 180]);

subplot(2,1,2);
plot(t, atan2(sin(theta_delayed-real_theta), cos(theta_delayed-real_theta)));
title('Error (measured - real)');
ylabel('\DeltaAngle (deg)');
xlabel('Time (s)');