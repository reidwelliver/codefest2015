function [newobj] = findPlate(imgray)

bw = edge(imgray, 'sobel');colormap gray;
bw = imdilate(bw,strel('disk',4));

%imagesc(bw);colormap gray;
[L, num] = bwlabel(bw, 4);

%imagesc(imgray)
zero=0*imgray;
for i = 1:num
    pix = L==i;
    obj=zero;
    obj(pix)=1;
    objsize=bwarea(obj);
    if objsize > 3000 % && size < 3000
        x=find(any(obj)==1);
        x=max(x)-min(x);
        y=find(any(obj,2)==1);
        y=max(y)-min(y);

        if (y*x-objsize)<6000
            imgray = mat2gray(imgray);
            newobj = mat2gray(bwconvhull(obj));
            newobj = newobj.*imgray;
            %text detect
         %   text = detectText(bcrop(newobj))
          
            imagesc(newobj)
            drawnow
        end;
    end
    
end;
