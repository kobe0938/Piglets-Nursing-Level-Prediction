clear;clc;

load time_list_03052236-
load data_list_03052236-
fs = 500;
data = normalize(data_list);
window_len = 5; % seconds
stride = floor(window_len * fs/2);

%% Energy Features
[energy_mean, energy_min, energy_max, energy_var] = extract_energy_features(data,fs,window_len,stride);

%% Time Domain Features
[time_mean, time_min, time_max, time_var] = extract_time_domain_features(data,fs,window_len,stride);

%% Frequency Domain Features (takes a long time)
band_width = 10; % Hz
[freq, freq_mean, freq_var] = extract_freq_domain_features(data,fs,window_len,band_width,stride);

%% Output a table of features

window_time = get_time_for_window(time_list,fs,window_len,stride);
T = table(window_time, energy_mean, energy_min, energy_max, energy_var,...
    time_mean, time_min, time_max, time_var,...
    freq_mean, freq_var);

%% add label to T

T.label = category_label;

% T.window_time = posixtime(T.window_time);
% writetable(T,'data.csv');

%% functions

function [energy_mean, energy_min, energy_max, energy_var] = extract_energy_features(data,fs,window_len, stride)

energy = data.^2;
num_points_per_window = window_len * fs;
energy_mean = movmean(energy, num_points_per_window);
energy_max = movmax(energy, num_points_per_window);
energy_min = movmin(energy, num_points_per_window);
energy_var = movvar(energy, num_points_per_window);

idx = floor(num_points_per_window/2):stride:length(data);
energy_mean = energy_mean(idx);
energy_max = energy_max(idx);
energy_min = energy_min(idx);
energy_var = energy_var(idx);

end

function [time_mean, time_min, time_max, time_var] = extract_time_domain_features(data,fs,window_len,stride)

num_points_per_window = window_len * fs;
time_mean = movmean(data, num_points_per_window);
time_max = movmax(data, num_points_per_window);
time_min = movmin(data, num_points_per_window);
time_var = movvar(data, num_points_per_window);

idx = floor(num_points_per_window/2):stride:length(data);
time_mean = time_mean(idx);
time_max = time_max(idx);
time_min = time_min(idx);
time_var = time_var(idx);

end


function [freq, freq_mean, freq_var] = extract_freq_domain_features(data,fs,window_len,band_width,stride)

num_points_per_window = window_len * fs;

tX = tall(data);
fcn = @(x) get_fft_res(x,fs,band_width);
[f_tall, freq_tall, freq_var_tall] = matlab.tall.movingWindow(fcn,num_points_per_window,tX,'Stride',stride);
freq = gather(unique(f_tall,'rows'));
freq_mean = gather(unique(freq_tall,'rows'));
freq_var = gather(unique(freq_var_tall,'rows'));
end


function [f_tall, freq_tall, freq_var_tall] = get_fft_res(data_section,fs,band_width)

L = length(data_section);
Y = fft(data_section);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1 = P1';
f = fs*(0:(L/2))/L;

n_bin = floor(fs/2/band_width);
f_tall = zeros(1,n_bin); freq_tall = zeros(1,n_bin); freq_var_tall = zeros(1,n_bin);

for i = 1:n_bin % loop over all freq. bands
    start_f = band_width*(i-1);
    end_f = band_width*(i);
    f_tall(1,i) = band_width/2 + (i-1)*band_width;
    idx_range = find(f > start_f & f < end_f);
    freq_tall(1,i) = mean(P1(idx_range));
    freq_var_tall(1,i) = var(P1(idx_range));
end

end

function window_time = get_time_for_window(time,fs,window_len,stride)

num_points_per_window = window_len * fs;
idx = floor(num_points_per_window/2):stride:length(time);
window_time = time(idx);

end

