%% Init
clear;
warning('off');
addpath(genpath('colorspace'));
addpath(genpath('gist'));
addpath(genpath('vlfeat-0.9.20-bin'));
addpath(genpath('manifold ranking'));
addpath(genpath('superpixels'));
addpath(genpath('graphcut'));

mainpath = './data/';
outputpath = './result/';
dataset_name = 'Internet image dataset';
class_name = {'airplane','car','horse'};%
% dataset_name = 'THUR15K';
% class_name = {'butterfly','coffeemug','dogjump','giraffe','plane'};%

%% Extact path and files
for i = 1:length(class_name);
    im_Dir = [mainpath dataset_name '/' class_name{1,i} '/Image/' ];
    gt_Dir = [mainpath dataset_name '/' class_name{1,i} '/GroundTruth/'];
    sal_Dir1 = [mainpath dataset_name '/' class_name{1,i} '/DRFI/' ]; 
    sal_Dir2 = [mainpath dataset_name '/' class_name{1,i} '/ST/'];
    sal_Dir3 = [mainpath dataset_name '/' class_name{1,i} '/DSR/'];
    sal_Dir4 = [mainpath dataset_name '/' class_name{1,i} '/RBD/'];
    sal_Dir5 = [mainpath dataset_name '/' class_name{1,i} '/MC/'];
    sal_Dir6 = [mainpath dataset_name '/' class_name{1,i} '/EQCUT/'];
    SP_Dir = [ './superpixels/' dataset_name '/'];
    imSuffix = '.jpg';
    gtSuffix = '.png';
    salSuffix1 = '_DRFI.png';
    salSuffix2 = '_ST.png';
    salSuffix3 = '_DSR.png';
    salSuffix4 = '_RBD.png';
    salSuffix5 = '_MC.png';
    salSuffix6 = '_EQCUT.png';
    imfiles = dir(fullfile(im_Dir, strcat('*', imSuffix)));
%% Feature extraction
    disp('Feature extraction');
    data = cell(size(imfiles,1),1);
    for k = 1:length(imfiles)
        disp(k);
        imName = imfiles(k).name(1:end-length(imSuffix));
        % extract file
        im = imread([im_Dir imName imSuffix]);
        im = im2double(im);
        gt = imread([gt_Dir imName gtSuffix]);
        gt = im2double(gt);
        sal1 = imread([sal_Dir1 imName salSuffix1]);
        sal1 = im2double(sal1);
        sal2 = imread([sal_Dir2 imName salSuffix2]);
        sal2 = im2double(sal2);
        sal3 = imread([sal_Dir3 imName salSuffix3]);
        sal3 = im2double(sal3);
        sal4 = imread([sal_Dir4 imName salSuffix4]);
        sal4 = im2double(sal4);
        sal5 = imread([sal_Dir5 imName salSuffix5]);
        sal5 = im2double(sal5);
        sal6 = imread([sal_Dir6 imName salSuffix6]);
        sal6 = im2double(sal6);
        [w,h,dim] = size(im);
        if dim == 1
            im = repmat(im,1,1,3);
        end
        [w1,h1,dim1] = size(sal1);
        if dim1 ~= 1
            sal1 = rgb2gray(sal1);
        end
        [w2,h2,dim2] = size(sal2);
        if dim2 ~= 1
            sal2 = rgb2gray(sal2);
        end
        [w3,h3,dim3] = size(sal3);
        if dim3 ~= 1
            sal3 = rgb2gray(sal3);
        end
        [w4,h4,dim4] = size(sal4);
        if dim4 ~= 1
            sal4 = rgb2gray(sal4);
        end
        [w5,h5,dim5] = size(sal5);
        if dim5 ~= 1
            sal5 = rgb2gray(sal5);
        end
        [w6,h6,dim6] = size(sal6);
        if dim6 ~= 1
            sal6 = rgb2gray(sal6);
        end
        [w7,h7,dim7] = size(gt);
        if dim7 ~= 1
            gt = rgb2gray(gt);
        end
        clear w1 w2 w3 w4 w5 w6 w7 h1 h2 h3 h4 h5 h6 h7 dim1 dim2 dim3 dim4 dim5 dim6 dim7
        % average saliency map
        sal1 = imresize(sal1,[w,h]);
        sal2 = imresize(sal2,[w,h]);
        sal3 = imresize(sal3,[w,h]);
        sal4 = imresize(sal4,[w,h]);
        sal5 = imresize(sal5,[w,h]);
        sal6 = imresize(sal6,[w,h]); 
        ave  = mat2gray(sal1+sal2+sal3+sal4+sal5+sal6);
        % image RGB hist
        [RGB_hist,RGB_hist_sal] = color_hist_short_sal(im,ave,'RGB'); %48 dim
        [RGB_hist,RGB_hist_gt] = color_hist_short_sal(im,gt,'RGB'); 
        % image Lab hist
        [Lab_hist,Lab_hist_sal] = color_hist_short_sal(im,ave,'Lab'); %48 dim
        [Lab_hist,Lab_hist_gt] = color_hist_short_sal(im,gt,'Lab');
        % gist
        gist = extract_gist(im); %512 dim
        % save imformation
        data{k}.im = im;  
        data{k}.gt = gt;
        data{k}.imName = imName; 
        data{k}.sal1 = mat2gray(sal1);
        data{k}.sal2 = mat2gray(sal2);
        data{k}.sal3 = mat2gray(sal3);
        data{k}.sal4 = mat2gray(sal4);
        data{k}.sal5 = mat2gray(sal5);
        data{k}.sal6 = mat2gray(sal6);
        data{k}.ave = ave;
        data{k}.gist = gist; 
        data{k}.Lab_hist_sal = Lab_hist_sal;
        data{k}.RGB_hist_sal = RGB_hist_sal;      
        data{k}.Lab_hist_gt = Lab_hist_gt;
        data{k}.RGB_hist_gt = RGB_hist_gt;
    end    
%% Random
    disp('Random');
    id = randperm(length(imfiles));
    p=ceil(length(imfiles)/3);
    dataset1=id(1:1:p);
    dataset2=id(p+1:1:2*p);
    dataset3=id(2*p+1:1:length(imfiles));
%% Retrieve rank
    disp('Retrieve rank');
    [ranklist,Dist_im] = retrieve_rank_cross(data,id,dataset1,dataset2,dataset3);
    similarnum = 6;  
    outdir = [outputpath dataset_name '/' class_name{1,i}];
    for d = 1:length(data)
%% Similar image saliency fusion        
        disp('Similar image saliency fusion');
        disp(d);      
        sfusion_salmap = similar_fusion_cross(data,d,ranklist,Dist_im,similarnum);
        data{d}.sfusion_salmap = sfusion_salmap;
        sfusion_salmap1 = im2uint8(sfusion_salmap); 
        outname = fullfile([outdir,'/sfusion_salmap/',data{d}.imName,'_sfusion.png']);
        imwrite(sfusion_salmap,outname);  
%% Correspondence saliency transfer
        disp('Correspondence saliency transfer');
        disp(d);
        spnumber1 = 150;
        spnumber2 = 200;
        spnumber3 = 250;
        spnumber4 = 300;
        spnumber5 = 350;
        spnumber6 = 400;
        spnumber7 = 450;
        spnumber8 = 500;
        co_salmap1 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber1);
        co_salmap2 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber2);
        co_salmap3 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber3);
        co_salmap4 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber4);
        co_salmap5 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber5);
        co_salmap6 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber6);
        co_salmap7 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber7);
        co_salmap8 = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber8);
        co_salmap = mat2gray(co_salmap1+co_salmap2+co_salmap3+co_salmap4+co_salmap5+co_salmap6+co_salmap7+co_salmap8);
        data{d}.co_salmap = co_salmap;
        co_salmap0 = im2uint8(co_salmap); 
        outname = fullfile([outdir,'/co_salmap/',data{d}.imName,'_co.png']);
        imwrite(co_salmap0,outname);        
%% Final saliency fusion
        disp('Final saliency fusion');
        disp(d);    
        final_salmap = mat2gray(sfusion_salmap.*co_salmap);      
        data{d}.final_salmap = final_salmap;
        final_salmap1 = im2uint8(final_salmap);
        outname = fullfile([outdir,'/multiple/',data{d}.imName,'_multiple.png']);
        imwrite(final_salmap1,outname);
    end
end    