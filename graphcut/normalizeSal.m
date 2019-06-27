function [ out ] = normalizeSal( img )
img = double(img);
out=(img-min(img(:)))/(max(img(:))-min(img(:))+eps);
end

