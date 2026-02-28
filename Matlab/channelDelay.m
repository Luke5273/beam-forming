function y = channelDelay(x, Fs, delay, varargin)
% CHANNELDELAY Applies propagation delay to a signal
%
% Inputs:
%   x      → input signal (vector)
%   Fs     → sampling frequency (Hz)
%   delay  → delay in seconds
%
% Optional name-value args:
%   'Attenuation' → linear gain (default = 1)
%   'NoisePower'  → AWGN power (default = 0)
%
% Output:
%   y → delayed signal

% ---- defaults ----
atten = 1;
noisePower = 0;

% ---- parse optional args ----
for k = 1:2:length(varargin)
    switch lower(varargin{k})
        case 'attenuation'
            atten = varargin{k+1};
        case 'noisepower'
            noisePower = varargin{k+1};
    end
end

% ---- fractional delay implementation ----
N = length(x);
t = (0:N-1)/Fs;

% delayed time axis
td = t - delay;

% interpolate
y = interp1(t, x, td, 'linear', 0);

% attenuation
y = atten * y;

% add noise
if noisePower > 0
    y = y + sqrt(noisePower)*randn(size(y));
end
end