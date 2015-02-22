function out = testOCR(I)
I = imresize(I,8);
%th = graythresh(I);
%BW = im2bw(I, th);
%figure;
%imshowpair(I, BW, 'montage');
Icorrected = imtophat(I, strel('disk', 40));

%th  = graythresh(Icorrected);
%BW1 = im2bw(Icorrected, th);
%figure;
%imshowpair(Icorrected, BW1, 'montage');

% Perform morphological reconstruction and show binarized image.
marker = imerode(Icorrected, strel('line',2,0));
Iclean = imreconstruct(marker, Icorrected);

th  = graythresh(Iclean);
BW2 = im2bw(Iclean, th);
BW2 = imdilate(BW2,strel('line',2,90));
BW2 = imerode(BW2, strel('disk',1));
%figure;
%imshowpair(Iclean, BW2, 'montage');
out = [];
[L, num] = bwlabel(BW2, 4);
for i = 1:num
    pix = L == i;

    objsize = bwarea(pix);
    if objsize>60000 && objsize<80000
        hull = bwconvhull(pix);
       % imagesc(pix);colormap gray;drawnow
        pix = BW2.*hull;
        
        results = ocr(pix,'CharacterSet', '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-''''', 'TextLayout', 'Block');
        text = results.Text;
        if length(text)>3
            out = [out text]
        end;
    end
end
%word = results.Words{1};
% Location of the word in I
%wordBBox = results.WordBoundingBoxes(1,:);
%figure;
%Iname = insertObjectAnnotation(I, 'rectangle', wordBBox, word);
%imshow(Iname);