function frame = findPlate(imgray,count)
outName = sprintf('outimage%d.tif',count);
%imgray = gpuArray(imgray);
imfilt = imgray;
filt = fspecial('gaussian', [5 5], 1);
 for j = 1:100 %number of low pass filter iterations
    imfilt = imfilter(imfilt, filt, 'replicate');
 end
 
imfilt = medfilt2(imfilt, [3 3]);
mich= max(imgray-imfilt, 0);

th = graythresh(mich);
bw = im2bw(mich,th);
bw = imdilate(bw,strel('disk',1));
bw = imerode(bw,strel('disk',1));

%imagesc(bw);colormap gray;
[L, num] = bwlabel(bw, 4);
% 

imagesc(imgray);colormap gray;axis image;hold on; 
for i = 1:num
    pix = L==i;
    % obj=zero;
    %  obj(pix)=1;
    objsize=bwarea(pix);
    if objsize > 500
        
        hull = bwconvhull(pix);
        hullsize=bwarea(hull);
        if hullsize > 1400  && hullsize < 3500
            
            x=find(any(hull)==1);
            x=max(x)-min(x);
            y=find(any(hull,2)==1);
            y=max(y)-min(y);
            
            if (y*x-hullsize)<1800 && x>y && x < 150
                %   hullsize
                B=bwboundaries(hull);
                plot(B{1}(:,2),B{1}(:,1),'-g', 'LineWidth',2)
                %  newobj = mat2gray(hull).*mat;
                %imagesc(newobj);colormap gray; drawnow
                %    out = [out testOCR(bcrop(newobj))];
                
            end;
        end
    end
end;
drawnow
frame = getframe(gcf);
imwrite(frame.cdata,outName);
end