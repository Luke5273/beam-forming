clear; close all;
rng('shuffle');
c = 343; %sound
trials = 10;

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

angles = 0:pi/64:2*pi;
distances = 0:0.01:8;

average_error = zeros(1, length(distances));

for distance_iter = 1:length(distances)
    
    distance = distances(distance_iter);
    
    for angle_iter = 1:length(angles)
        
        angle = angles(angle_iter);
        beacon_pos = distance*[cos(angle) sin(angle)];
        
        dist_to_mic = zeros(1, num_mics);
        time_to_mic = zeros(1, num_mics);
        
        mic_pos_x = zeros(1, num_mics);
        mic_pos_y = zeros(1, num_mics);
        
        err = 0;
        for trial = 1:trials
            for i = 1:num_mics
                mic_pos_x(i) = mic_pos(i, 1);
                mic_pos_y(i) = mic_pos(i, 2);
            
                dist_to_mic(i) = sqrt((beacon_pos(1)-mic_pos_x(i))^2 + (beacon_pos(2)-mic_pos_y(i))^2);
                jitter = thermal_noise_sigma*randn() + timing_window*(2*rand-1);
                time_to_mic(i) = dist_to_mic(i)/c + jitter;
            end
            
            ref = 1;
            
            tau = time_to_mic - time_to_mic(ref);
            
            A = mic_pos(2:end,:) - mic_pos(ref,:);
            b = -c * tau(2:end)';
            
            u = (A'*A)\(A'*b);
            u = u / norm(u);
            theta = atan2(u(2),u(1));
            err = err + abs(atan2(sin(theta-angle), cos(theta-angle)));

        end
        average_error(distance_iter) = average_error(distance_iter) + err/trials;
    
    end
    average_error(distance_iter) = rad2deg(average_error(distance_iter)/length(angles));

end

plot(distances, average_error);
grid on;
ylabel("Average error (deg)");
xlabel("Distance (m)");

%plot(mic_pos_x, mic_pos_y, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
%axis equal
%xlim([-8,8]);
%ylim([-8,8]);
%grid on;
%
%hold on;
%plot(beacon_pos(1), beacon_pos(2), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
%plot([0 cos(theta)], [0 sin(theta)], 'r--');
%plot([0 beacon_pos(1)], [0 beacon_pos(2)], 'k--');

