function [] = launch(filename)
close all
vd_orig = VideoReader(filename);

while hasFrame(vd_orig)
    frame = readFrame(vd_orig);
  %  imtool(frame)
    frame = rgb2gray(frame);
    %call frame processing function
    findPlate(frame);

end
