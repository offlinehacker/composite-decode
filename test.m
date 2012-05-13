m = load("tests/C1PAL00005.dat");

sample_time=m(2)-m(1);
sample_frequency= 1/sample_time;
frequency= sample_frequency/2;

[b,a]= butter(22,6000000/frequency);
n=filtfilt(b,a,m);
[frames,resample_time, colors] = video_extract(n);
[Y,C]=yc_demodulator(frames,resample_time);
[YUV]=chroma(Y,C,colors,resample_time);
imshow(YUV)
%newf = C(:,:,1) .+ abs(min(min(C(:,:,1))));
%new2 = newf ./ max(max(newf));
%[m,n]=size(new2)
%imshow(new2)
%figure;
%plot(m)
