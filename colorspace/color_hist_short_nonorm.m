function [ Color_hist ] = color_hist_short_nonorm( img, type, patch )

if nargin<2
    type='Lab';  
    patch=ones(size(img,1),size(img,2));
elseif nargin<3
    patch=ones(size(img,1),size(img,2));
end

para.numColorHistBins = 16-1;
%% Lab
if strcmp(type,'Lab')
% Compute the frame color histogram
para.LBinSize = 100 / para.numColorHistBins;
para.abBinSize = 256 / para.numColorHistBins;
para.LBinEdges = 0:para.LBinSize:100;
para.abBinEdges = -128:para.abBinSize:128;
% para.NUM_COLORS = 69;

%     [L,a,b] = RGB2Lab(double(img(:,:,1)), double(img(:,:,2)), double(img(:,:,3)));   
    imgLAB=colorspace('Lab<-',img); 
    L=imgLAB(:,:,1);
    a=imgLAB(:,:,2);
    b=imgLAB(:,:,3);
    Color_hist = [histc(L(patch>0), para.LBinEdges); ...
        histc(a(patch>0), para.abBinEdges); histc(b(patch>0), para.abBinEdges)];
    
    Color_hist = Color_hist';
%     Color_hist=Color_hist/sum(Color_hist);
      
%% RGB
elseif strcmp(type,'RGB')  
% para.numColorHistBins = 22;
para.rgbBinSize = 255 / para.numColorHistBins;
para.rgbBinEdges = 0:para.rgbBinSize:255;
% para.NUM_COLORS = 69;

    img=im2uint8(img);
    R=img(:,:,1);
    G=img(:,:,2);
    B=img(:,:,3);
    Color_hist = [histc(R(patch>0), para.rgbBinEdges); ...
        histc(G(patch>0), para.rgbBinEdges); histc(B(patch>0), para.rgbBinEdges)];
    
    Color_hist = Color_hist';
%     Color_hist=Color_hist/sum(Color_hist);
else
    error('error color type');
end

