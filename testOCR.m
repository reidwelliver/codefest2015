close all
I = imread('scott.png');
th = graythresh(I);
BW = im2bw(I, th);
figure;
imshowpair(I, BW, 'montage');
Icorrected = imtophat(I, strel('disk', 40));

th  = graythresh(Icorrected);
BW1 = im2bw(Icorrected, th);
figure;
imshowpair(Icorrected, BW1, 'montage');

% Perform morphological reconstruction and show binarized image.
marker = imerode(Icorrected, strel('line',2,0));
Iclean = imreconstruct(marker, Icorrected);

th  = graythresh(Iclean);
BW2 = im2bw(Iclean, th);

figure;
imshowpair(Iclean, BW2, 'montage');

[L, num] = bwlabel(BW2, 4);
for i = 1:num
    pix = L == i;
    objsize = bwarea(pix);
    if (objsize>1000)
        hull = bwconvhull(pix);
        pix = BW2.*hull;
        pix = imdilate(pix,strel('line',2,90));
        pix = imerode(pix, strel('disk',1));
        results = ocr(pix, 'TextLayout', 'Block');
        imtool(pix)
        results.Text
    end
end
word = results.Words{1};
% Location of the word in I
wordBBox = results.WordBoundingBoxes(1,:);
figure;
Iname = insertObjectAnnotation(I, 'rectangle', wordBBox, word);
imshow(Iname);