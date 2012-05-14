function [video_mat, resample_time, color_burst_mat]=video_extract2(raw_video, sync_threshold)
    % TODO: Calculate all parametera automatically
    [m,n]=size(raw_video);

    sync_threshold= -0.20

    sample_time=raw_video(2)-raw_video(1);
    sample_frequency= 1/sample_time;
    frequency= sample_frequency/2;

    pal_frequency= 4433618.75;

    printf("Sample time id %f, frequency is %d\n", sample_time, frequency);

    %threshold for sync detection
    vsync_period_threshold=(24*10^(-6))/sample_time;
    hsync_period_threshold=(4*10^(-6))/sample_time;

    % First vertical sync detection
    vsync_flag=0;
    hsync_flag=0;
    vsync_progress=0;
    vsync_counter=0;
    hsync_counter=0;
    end_of_1st_vsync=0;
    last_vsync=0;

    printf("Trying to detect vsynch\n");
    for i=1:m
        if raw_video(i,2) < sync_threshold
            vsync_counter=vsync_counter+1;
            if vsync_counter > vsync_period_threshold
                vsync_flag=1;
                last_vsync=i;
            end
        else
            if vsync_flag==1
                vsync_progress=vsync_progress+1;
                vsync_flag=0;
                vsync_counter=0;
                if vsync_progress == 5
                    printf("First vsynch detected at sample %d\n", i);
                    end_of_1st_vsync=i
                    vsync_progress=0;
                    break;
                end
            end
            if last_vsync>0 & last_vsync-i<5000
                vsync_counter=0;
            end
        end
    end

    if end_of_1st_vsync>(2/3)*m
        end_of_1st_vsync=1;
    end

    printf("End of first vsynch is at sample %d\n", end_of_1st_vsync);

    % From end of VSYNC, detect every HSYNC and store active video field
    % from video lines 10-262 for field0 and 272-525 for field1

    % End of VSYNC is at the end of line 6
    % Lines 7,8,9 has equalizing pulses and HSYNC pulse every half line period

    active_pxl_per_line= round((52*10^(-6))/sample_time);
    line_number=0;
    field_number=1;
    hsync_low2active_video=round(10.4*(10^(-6))/sample_time); %active video is 9.2us from falling edge of HSYNC
    hsync_low2color_burst=round(5.3*(10^(-6))/sample_time);%color burst starts 5.3us from falling edge of HSYNC
    color_burst_length=round(9*((1/pal_frequency)/sample_time));%color burst length is 9+-1 cycles of pal_frequency

    printf("Active pixels per line %d\n", active_pxl_per_line);

    i=end_of_1st_vsync;
    while i<=m
        % HSYNCH/VSYNCH detection case
        if raw_video(i,2) < sync_threshold
            hsync_counter=hsync_counter+1;
            vsync_counter=vsync_counter+1;
            if vsync_counter > vsync_period_threshold
                vsync_flag=1;
            end
            if(hsync_counter > hsync_period_threshold & hsync_counter < vsync_period_threshold)
                hsync_flag=1;
            else
                hsync_flag=0;
            end
        else
            % HSYNC case
            if hsync_flag == 1
                 printf("Hsync deteted at sample %d\n", i);

                line_number=line_number+1;
                start_of_active_vid=i-hsync_counter+hsync_low2active_video;
                [resampled,h]= resample(raw_video(start_of_active_vid:start_of_active_vid+active_pxl_per_line-1,2),720,active_pxl_per_line);
                video_mat(line_number,:,field_number)= resampled(:);
                resample_time=sample_time*(720/active_pxl_per_line);

                %Extracting the line color burst frequency
                start_of_color_burst=i-hsync_counter+hsync_low2color_burst;
                color_burst=raw_video(start_of_color_burst:start_of_color_burst+color_burst_length-10,:);

%               cb_interp=interp(color_burst,100)-color_burst(1);
%               cb_sign=sign(cb_interp)+1;
%            cb_zero_cross=diff(cb_sign);
    %            [zero_index,s]=find(cb_zero_cross>0);
    %            color_burst_mat(line_number,1,field_number)=1/(mean(diff(zero_index(4:end-
    %            4)))*37e-11);
    %            %color burst phase 1=0 degrees -1=180 degrees
    %            color_burst_mat(line_number,2,field_number)=cb_sign(700)/2;
    %i
                pin=ones(1,3);
                pin(2)=pal_frequency/(10^6);
                pin(3)=pi;
                F=inline('abs(p(1))*sin(2*pi*p(2)*10^6*x+p(3))','x', 'p');
                [f,p,kvg,iter,corp,covp,covr,stdresid,Z,r2]=leasqr(color_burst(:,1),color_burst(:,2),pin,F);
                color_burst_mat(line_number,:,field_number)=p;
                p

                %reseting counters and progress i to the next line
                i=start_of_active_vid+active_pxl_per_line-1;
                vsync_counter=0;
                hsync_counter=0;
                hsync_flag=0;

            % VSYNC case
            elseif vsync_flag==1
                vsync_progress=vsync_progress+1;
                vsync_flag=0;
                vsync_counter=0;
                hsync_flag=0;
                hsync_counter=0;
                if vsync_progress == 6
                    printf("Vsync detected at sample %d\n", i);
                    line_number=0;
                    field_number=field_number+1
                    vsync_progress=0;
                end
            % Equalizing pulses case
            else
                vsync_counter=0;
                hsync_counter=0;
            end

        end
        i=i+1;
    end
