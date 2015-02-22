function [] = launch(filename)
close all
vd_orig = VideoReader(filename);
numSkip = 0;

while hasFrame(vd_orig)
    frame = readFrame(vd_orig);
  %  imtool(frame)
    frame = rgb2gray(frame);
    %call frame processing function
    frameQual = findPlate(frame);
    % Try to skip some frames
    if frameQual == 0
        numSkip = 0;
    else
        numSkip = numSkip + frameQual;
        count = 0;
        while count < numSkip
            if hasFrame(vd_orig)
                readFrame(vd_orig);
            end
            count = count +1;
        end
    end

end
