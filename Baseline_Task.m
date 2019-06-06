%how long do you want to record for
seconds_of_data = 300;
%record baseline physio data
Screen('Preference', 'SkipSyncTests', 1 );
%need to add in participant number
subject_code = input('Enter subject code: ','s');
baseline_file_name = sprintf('data\\%s_Baseline_Physio.txt',subject_code);
baseline_file = fopen(baseline_file_name,'w');
exp_screen=max(Screen('Screens'));
windowptr = Screen('OpenWindow', exp_screen);
grayLevel = [0 0 0];
markercolor = 255;%marker color

Screen('FillRect',windowptr,grayLevel);
Screen('TextSize', windowptr, 60); %Set textsize
Screen('TextFont',windowptr, 'Helvetica'); %Set text font
Screen('TextColor',windowptr,255); %Set text color
DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
[start_time] = Screen('Flip',windowptr);
first_flip_time = now();
fprintf(baseline_file, 'start_time: %1.6f\n', first_flip_time);

total_time = GetSecs() - start_time;
while(total_time < seconds_of_data)
    pause(15)
    total_time = GetSecs() - start_time;
end

close_time=now();
fprintf(baseline_file, 'end_time: %1.6f\n', close_time);
fclose(baseline_file);
Screen('CloseAll');