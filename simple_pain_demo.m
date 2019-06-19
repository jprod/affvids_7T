%%Test pain script
addpath('pressure_pain-master')

%% set up ports - taken directly from setupPPD
delete(instrfindall) %clear out old channels

%localhost
t=udp('localhost',61557); % creates a local host with this ID - interacts with lab view
%- this is the port that is written to
%where do these hard coded numbers comes from how do they relate to lab
%view

%udp(RemoteHost,RemotePort) creates a UDP object with the specified remote port value, RemotePort. If not specified, the default remote port is 9090.
r=udp('localhost',61158,'localport', 61556); % this is the port that seems to be read from



fopen(t);
fopen(r);
fwrite(t, '0005,0010,o'); % open the remote channel
%% Stimululation administration
%why is it inside eval?
%fwrite writes a binary file
%I think this may actually just be two arguments t and ''' sprintf('%04d',int(2)) ',' sprintf('%04d',dur) ',t''
% with int(2) = 4 and dur = 3
%'fwrite(t, '0004,0003,t');'
% the first t will be converted as it is a variable (not a string)
% not so sure about the second t
intensity = 7;
duration = 3;

eval(['fwrite(t, ''' sprintf('%04d',intensity) ',' sprintf('%04d',dur) ',t'');']);



%% only time I see that R is used
% message_1 = deblank(fscanf(r));
% if strcmp(message_1,'Read Error')
%             error(message_1);
% end
      
fclose(t);
fclose(r);