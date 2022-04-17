function data = readGeoscopePackets(filename,sample_rate,tz)
%readGeoscopeFile imports a single .json File of Geophone Data
%  reads in a json file located at filename and arranges all samples from it,
%	creating a time scale for each packet as well.
%
%  filename: file to be read in
%  sample_rate (optional): rate the sensors were set to sample at, Hz
%	(defaults to 10 kHz)
%  tz (optional): time zone for sensor data
%
%  return value: a structure containing two matrices:
%	data is the sample_count × packet_count data points array
%	time is the same sized time points array (as datetime objects)
%
	narginchk(1,3); % Validate input argument count
	if nargin < 2
		sample_rate = 10e3; % set default sample rate, Hz
	end
	if nargin < 3
		tz = 'America/Chicago'; % default time zone
	end


	tick = 1/sample_rate; % time period between samples (one clock "tick")
	rawImport = jsondecode(fileread(filename)); % read the file
	rawData = []; time = datetime.empty;
		% declare storage arrays for the loops
	timeFormat = 'dd-MMM-yyyy HH:mm:ss.SSSSSS'; % define format
	time.Format = timeFormat; time.TimeZone = tz;
		% set the storage array to use them

	for i = 1:length(rawImport) % for sample set in the file
		% load the data points
		thisData = rawImport(i).data;
		% convert the timestamp to seconds
		rawImport(i).timestamp = round(rawImport(i).timestamp/1e3);
			% the sub-second values are unreliable. Dropping them.
		% generate the time vector
		thisTime = flip(rawImport(i).timestamp:-tick:...
			rawImport(i).timestamp...
			-(tick*(length(thisData)-1)))';
		% start from the posted timestamp, stepping backwards by
		%	tick up to the proper length
		% convert timestamps to datetime format
		thisTime = datetime(thisTime,...
			'convertFrom','posixtime',...
			'TimeZone',tz,... % using the same timezone
			'Format',timeFormat); % and format
		rawData = [rawData,thisData(1:end)]; % add the data
		time = [time,thisTime(1:end)]; % and time points
	end
	[time,sortedIdx] = sortrows(time');
	data.data = rawData(:,sortedIdx);
	data.time = time';

end
