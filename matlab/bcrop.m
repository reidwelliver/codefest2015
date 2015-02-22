function [crop] = bcrop(imgray)
x=find(any(imgray)==1);
xmin=min(x);
width=max(x)-xmin;
y=find(any(imgray,2)==1);
ymin=min(y);
height=max(y)-ymin;
crop = imcrop(imgray,[xmin ymin width height]);