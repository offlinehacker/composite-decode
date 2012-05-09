m = load("tests/C1PAL00005.dat");
[frames, colors] = video_extract(m);
newf = frames .+ abs(min(min(frames)));
new2 = newf ./ max(max(newf))
imshow(new2)
figure;
plot(m)
