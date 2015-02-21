function [] = launch(filename)
vd_orig = VideoReader(filename);
figa = figure;
figb = figure;
while hasFrame(vd_orig)
    frame = readFrame(vd_orig);
    imtool(frame)
    frame = rgb2gray(frame);
    %call frame processing function
    findCars(frame);

end
