function [text] = detectText_Alone%(grayImage)
%colorImage = imread(grayImage);
close all
grayImage = imread('scott.tif');

text = '';
showPlots = 1;
if showPlots == 0
     imagesc(grayImage); title('Original image')
end;
% Detect and extract regions
%grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));  % extract regions

% Visualize the MSER regions overlaid on the original image
if showPlots
    figure; imshow(grayImage); hold on;
    plot(mserRegions, 'showPixelList', true,'showEllipses',false);
    title('MSER regions');
end

% Convert MSER pixel lists to a binary mask
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;

% Run the edge detector
edgeMask = edge(grayImage, 'Canny');

% Find intersection between edges and MSER regions
edgeAndMSERIntersection = edgeMask & mserMask;
if showPlots
    figure; imshowpair(edgeMask, edgeAndMSERIntersection, 'montage');
    title('Canny edges and intersection of canny edges with MSER regions')
end

[~, gDir] = imgradient(grayImage);
% You must specify if the text is light on dark background or vice versa
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
if showPlots
    figure; imshow(gradientGrownEdgesMask); title('Edges grown along gradient direction')
end

% Remove gradient grown edge pixels
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;

% Visualize the effect of segmentation
if showPlots
    figure; imshowpair(mserMask, edgeEnhancedMSERMask, 'montage');
    title('Original MSER regions and segmented MSER regions')
end

%myMask = edgeEnhancedMSERMask;
%myMask = gradientGrownEdgesMask;
myMask = mserMask;
connComp = bwconncomp(myMask); % Find connected components
stats = regionprops(connComp,'Area','Eccentricity','Solidity');

% Eliminate regions that do not follow common text measurements
regionFilteredTextMask = myMask;

%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .9999})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 10 | [stats.Area] > 600})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;

% Visualize results of filtering
if showPlots
    figure; imshowpair(myMask, regionFilteredTextMask, 'montage');
    title('Text candidates before and after region filtering')
end
chosenMask = myMask;
%chosenMask = regionFilteredTextMask;
distanceImage    = bwdist(~chosenMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image

% Show stroke width image
if showPlots
    figure; imshow(strokeWidthImage);
    caxis([0 max(max(strokeWidthImage))]); axis image, colormap('jet'), colorbar;
    title('Visualization of text candidates stroke width')
end

% Find remaining connected components
connComp = bwconncomp(chosenMask);
afterStrokeWidthTextMask = chosenMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end

% Visualize the effect of stroke width filtering
if showPlots
    figure; imshowpair(chosenMask, afterStrokeWidthTextMask,'montage');
    title('Text candidates before and after stroke width filtering')
end

se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);

% Display image region corresponding to afterMorphologyMask
% if showPlots
%     displayImage = grayImage;
%     displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
%     figure; imshow(displayImage); title('Image region under mask created by joining individual characters')
% end

areaThreshold = 5000; % threshold in pixels
connComp = bwconncomp(afterMorphologyMask);
stats = regionprops(connComp,'BoundingBox','Area');
boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
if showPlots
    for i=1:size(boxes,1)
        figure;
        imshow(imcrop(colorImage, boxes(i,:))); % Display segmented text
        title('Text region')
    end
end

ocrtxt = ocr(afterStrokeWidthTextMask, boxes); % use the binary image instead of the color image

if ~isempty(ocrtxt)
    text = ocrtxt.Text;
end;

end