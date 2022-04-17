clear;clc;

folder = '/Users/yiwendong/Box Sync/USDA Pig Farm/Cycle 2 Pen 3 Farrowing/Data/2021-';
date = '03-06';
fs = 500;
sensor_list = [30]; % 30, 31, 32, 34
hour_list = [1,2,3];
target_start_time = datetime(['2021-' date ' ' num2str(hour_list(1)) ':00:00'],...
    'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone', 'America/Chicago');
target_stop_time = datetime(['2021-' date ' ' num2str(hour_list(length(hour_list))) ':59:00'],...
    'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone', 'America/Chicago');
d = {};
for sen = 1:length(sensor_list) % loop over sensors
    sensor_num = sensor_list(sen);
    sensor_name = strcat('/GEOSCOPE_SENSOR_', int2str(sensor_num));
    path = strcat(strcat(folder,date), sensor_name);
    FolderInfo = dir(path);
    
    data_list = []; time_list = []; freq_list = []; engy_list = []; psd_list = []; 
    section_time = [];
    for file_num = 3: numel(FolderInfo) % loop over files in the sensor folder
        file_name = FolderInfo(file_num).name;
        hour_of_file = str2double(file_name(12:13));
        
        if ismember(hour_of_file,hour_list) % select the hours according to hour list
            % read file
            file = strcat(strcat(path,'/'),file_name);
            data_struct = readGeoscopePackets(file,fs);
            data = data_struct.data(:);
            time = data_struct.time(:);

            clearvars wrong_time_idx
            wrong_time_idx = find(time<target_start_time | time>target_stop_time);
            if ~isempty(wrong_time_idx)
                correct_time_idx = find(time>=target_start_time & time<=target_stop_time);
                data_list = [data_list; data(correct_time_idx)];
                time_list = [time_list; time(correct_time_idx)];
            else
            % save to the lists
                data_list = [data_list; data];
                time_list = [time_list; time];

            end
        end
        
    end
    disp(log(sum(engy_list)))

    plot_data(time_list, data_list)
    d{sen,1} = time_list;
    d{sen,2} = data_list;
end


%%
function [f, P1, energy, pxx] = get_freq_spectrum(data_section, fs)
    data = detrend(data_section);
    Y = fft(data);
    Y_sq = Y.*conj(Y);
    L = length(data_section);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(L/2))/L;
    energy = 2*sum(Y_sq(f <= 100)) * fs/L;
    pxx = 0; %pwelch(data);
    
end

function plot_data(t, data)
    figure
    plot(t,data)
    xlabel('Time')
    ylabel('Signal Magnitudes')
    title('Raw Data Plot')
    
end

