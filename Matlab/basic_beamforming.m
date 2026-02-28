clear; close all;
rng('shuffle');
c = 343; %sound
trials = 10;
Fs = 10e3;

thermal_noise_sigma = 50e-6;
timing_window = 100e-6;

mic_pos = [
    0 0;
    1 1;
    1 -1;
    -1 1;
    -1 -1
];
num_mics = size(mic_pos, 1);

target_pos = [5 2];

fc = 1e3;
t = 0:1/Fs:10*2*pi*fc;
x = sin(2*pi*fc*t);

distances = sqrt((mic_pos(:, 1)-target_pos(1)).^2 + (mic_pos(:, 2)-target_pos(2)).^2);
tau = distances/c;

y = zeros(size(x));
for i = 1:num_mics
    tau_i = tau(i);
    delay_samples = tau_i * Fs;
    
    n = 0:length(x)-1;
    delayed = interp1(n, x, n-delay_samples, 'spline', 0);
    
    y = y + delayed;
end

plot(t, y);
