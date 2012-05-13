m = load("tests/C1PAL00005.dat");
[frames, colors] = video_extract(m);
newf = frames(:,:,1) .+ abs(min(min(frames(:,:,1))));
new2 = newf ./ max(max(newf));
imshow(new2)
figure;
plot(m)
