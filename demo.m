clear;
path_in = '.\data\THUR15K\butterfly\Image\';
path_out = '.\data\THUR15K\butterfly\Image\';
mkdir(path_out);
imSuffix = '.jpg';
imfiles = dir(fullfile(path_in, strcat('*', imSuffix)));
for k = 1:length(imfiles)
    disp(k);
    imName = imfiles(k).name(1:end-length(imSuffix));
    im = imread([path_in imName imSuffix]);
    [w,h,dim] = size(im);
    if dim == 1
        im = repmat(im,1,1,3);
    end
    outname = fullfile([path_out,imName,'.jpg']);
    imwrite(im,outname);
end