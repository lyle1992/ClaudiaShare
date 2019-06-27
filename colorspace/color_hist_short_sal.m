function [ Color_hist,Color_hist_sal ] = color_hist_short_sal( img, sal,type, patch )

if nargin<3
    type='Lab';  
    patch=ones(size(img,1),size(img,2));
elseif nargin<4
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
   %% sal weighted%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [hist_R,bin_R]=histc(L(patch>0), para.LBinEdges);
    [hist_G,bin_G]=histc(a(patch>0), para.abBinEdges); 
    [hist_B,bin_B]=histc(b(patch>0), para.abBinEdges);
    for i=1:para.numColorHistBins+1
     hist_R_sal(i,1)=mean(sal(find(bin_R==i)))*hist_R(i);
     hist_G_sal(i,1)=mean(sal(find(bin_G==i)))*hist_G(i);
     hist_B_sal(i,1)=mean(sal(find(bin_B==i)))*hist_B(i);
    end
    Color_hist_sal=[hist_R_sal;hist_G_sal;hist_B_sal]';
    Color_hist_sal(isnan(Color_hist_sal)==1)=0; %meansal不存在时
    Color_hist_sal=Color_hist_sal/sum(Color_hist_sal);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Color_hist = [hist_R;hist_G;hist_B];
    Color_hist = Color_hist';
    Color_hist=Color_hist/sum(Color_hist);
      
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
    %% sal weighted%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [hist_R,bin_R]=histc(R(patch>0), para.rgbBinEdges);
    [hist_G,bin_G]=histc(G(patch>0), para.rgbBinEdges); 
    [hist_B,bin_B]=histc(B(patch>0), para.rgbBinEdges);

    for i=1:para.numColorHistBins+1
     hist_R_sal(i,1)=mean(sal(find(bin_R==i)))*hist_R(i);
     hist_G_sal(i,1)=mean(sal(find(bin_G==i)))*hist_G(i);
     hist_B_sal(i,1)=mean(sal(find(bin_B==i)))*hist_B(i);
    end
    Color_hist_sal=[hist_R_sal;hist_G_sal;hist_B_sal]';
    Color_hist_sal(isnan(Color_hist_sal)==1)=0; %meansal不存在时
    Color_hist_sal=Color_hist_sal/sum(Color_hist_sal);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Color_hist = [hist_R;hist_G;hist_B];
    Color_hist = Color_hist';
    Color_hist=Color_hist/sum(Color_hist);
else
    error('error color type');
end

