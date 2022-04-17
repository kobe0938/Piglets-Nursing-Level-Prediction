% clear;clc;

load time_S32_longer
load data_S32_longer
fs = 500;
piglet_out = datetime({'05-Mar-2021 23:34:46'; '06-Mar-2021 00:22:53'...
    ; '06-Mar-2021 00:32:07'; '06-Mar-2021 00:58:46'; '06-Mar-2021 01:10:05'; '06-Mar-2021 01:41:37'...
    ; '06-Mar-2021 01:59:35'; '06-Mar-2021 02:02:37'; '06-Mar-2021 02:12:09'...
    ; '06-Mar-2021 02:22:01'; '06-Mar-2021 02:30:29'; '06-Mar-2021 02:52:26'},'TimeZone','America/Chicago');
piglet_num = 1:12;
data_n = normalize(data);

%% Energy

energy_mov1s = movmean(data_n.^2,fs);

figure
yyaxis left
plot(time, normalize(energy_mov1s,'range'),'-')
% xlabel("Time")
% ylabel("Energy Amplitude")
hold on
yyaxis right
plot(piglet_out,piglet_num,'r-o')
% plot(window_time, label_sow)
hold on
set(gcf,'Position',[500 500 1000 300])
legend('Normalized Signal Energy','No. of New Borns','Location','northwest')
set(gca,'fontsize', 15)

%% time

dt = 1; % time interval (s)
start = piglet_out(1) - 100*seconds(dt);
stop = start + 110*seconds(dt);
stop_idx = find(time == stop);
start_idx = find(time == start);

data_section = data_n(start_idx:stop_idx);
time_section = time(start_idx:stop_idx);
plot(time_section,data_section)
xlabel("Time")
ylabel("Signal Amplitude")



%% Frequency

dt = 5; % time interval (s)
start = piglet_out(3) - seconds(dt/2);
stop = start + seconds(dt/2);
stop_idx = find(time == stop);
start_idx = find(time == start);

data_section = data_n(start_idx:stop_idx);
L = length(data_section);
Y = fft(data_section);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f,P1)
xlabel("Frequency (Hz)")
ylabel("Amplitude")
