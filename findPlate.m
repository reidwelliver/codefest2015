function [frameQual] = findPlate(imgray)
frameQual = 5;
imagesc(imgray)
drawnow
% disp('Starting frame at');
% datestr(now)

bw = edge(imgray, 'sobel');colormap gray;
bw = imdilate(bw,strel('disk',4));

%imagesc(bw);colormap gray;
[L, num] = bwlabel(bw, 4);

%imagesc(imgray)
zero=0*imgray;
for i = 1:num
%parfor i = 1:num
    pix = L==i;
    obj=zero;
    obj(pix)=1;
    objsize=bwarea(obj);
    %imagesc(obj)
    if objsize > 3000 %&& objsize < 90000
        frameQual = frameQual-1;
        x=find(any(obj)==1);
        x=max(x)-min(x);
        y=find(any(obj,2)==1);
        y=max(y)-min(y);
        
        imagesc(obj)
        drawnow

        if (y*x-objsize)<6000
            par_imgray = mat2gray(imgray);
            newobj = mat2gray(bwconvhull(obj));
            newobj = newobj.*par_imgray;
            %text detect
         %   text = detectText(bcrop(newobj))
          
            imagesc(newobj)
            drawnow
        end;
    end
end
if frameQual < 0
    frameQual = 0;
end
% disp('Finished frame at');
% datestr(now)
