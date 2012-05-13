m = load("tests/C1PAL00003.dat");
[frames, colors] = video_extract(m);
[m,n]=size(frames)
newf = frames(:,:,1) .+ abs(min(min(frames(:,:,1))));
new2 = newf ./ max(max(newf));
imshow(new2)
figure;
plot(m)
