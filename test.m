m = load("tests/C1PAL00005.dat");

sample_time=m(2)-m(1);
sample_frequency= 1/sample_time;
frequency= sample_frequency/2;

[b,a]= butter(22,6000000/frequency);
n(:,1)=m(:,1);
n(:,2)=filtfilt(b,a,m(:,2));
[frames, colors] = video_extract1(n);
[Y,C]=yc_demodulator(frames,sample_time);
[YUV]=chroma(Y,C,colors,sample_time);

newYUV(:,:,1)=YUV(:,:,1).+abs(min(min(YUV(:,:,1))));
newYUV(:,:,2)=YUV(:,:,2).+abs(min(min(YUV(:,:,2))));
newYUV(:,:,3)=YUV(:,:,3).+abs(min(min(YUV(:,:,3))));
newYUV2(:,:,1)=newYUV(:,:,1)./max(max(newYUV(:,:,1)));
newYUV2(:,:,2)=newYUV(:,:,2)./max(max(newYUV(:,:,2)));
newYUV2(:,:,3)=newYUV(:,:,3)./max(max(newYUV(:,:,3)));
RGB=YUVtoRGB(newYUV2);

imshow(RGB)

%newf = C(:,:,1) .+ abs(min(min(C(:,:,1))));
%new2 = newf ./ max(max(newf));
%[m,n]=size(new2)
%imshow(new2)
%figure;
%plot(m)
