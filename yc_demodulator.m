function [Y,C]=yc_demodulator(video_mat,sample_time)
    [m,n,field]=size(video_mat);
    C=zeros(m,n,field);

    f=(1/sample_time)/2;
    [b1 a1] = butter(12, [3.1*10^6 5.8*10^6]./f, 'stop');
    [b2 a2] = butter(12, 3*10^6/f);

    for f=1:field
        for l=1:m
            C(l,:,f)=filtfilt(b1,a1,video_mat(l,:,f));
        end
    end

    for f=1:field
        for l=1:m
            Y(l,:,f)=filtfilt(b2,a2,video_mat(l,:,f));
        end
    end

