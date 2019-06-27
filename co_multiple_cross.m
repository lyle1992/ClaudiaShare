function [co_salmap] = co_multiple_cross(data,d,ranklist,Dist_im,similarnum,spnumber)
%原始图像超像素分割
im_o = im2uint8(data{d}.im);
[w,h,dim] = size(data{d}.im);
[idxImg,pixelList,spNum] = SLIC_Split(im_o,spnumber);
imLab = colorspace('Lab<-',im_o);
imLab_val = reshape(imLab,w*h,3);
lab_val = zeros(spNum,1,3);
ind = cell(spNum,1);  
for k = 1:spNum
    ind{k} = find(idxImg==k);
    lab_val(k,1,:) = mean(imLab_val(ind{k},:),1);
end
lab_val = reshape(lab_val,spNum,3); 
%保存不同相似图像的对应显著性图
co_sal = cell(similarnum,1);
for i = 1:similarnum
    %% 相似图像超像素分割
    imlabel = ranklist(d,i);
    im_s = im2uint8(data{imlabel}.im);
    [ws,hs,dims] = size(data{imlabel}.im);
    [idxImgs,pixelLists,spNums] = SLIC_Split(im_s,spnumber);
    imLabs = colorspace('Lab<-',im_s);
    imLab_vals = reshape(imLabs, ws*hs, 3);
    lab_vals = zeros(spNums,1,3);
    inds = cell(spNums,1);  
    for kk = 1:spNums
        inds{kk} = find(idxImgs==kk);
        lab_vals(kk,1,:) = mean(imLab_vals(inds{kk},:),1);
    end
    lab_vals = reshape(lab_vals,spNums,3); 
    
    %% single edges
    [edgesindext1,edges1,bd1] = getedges(idxImg,spNum); 
    [edgesindext2,edges2,bd2] = getedges(idxImgs,spNums);
    edges2 = edges2+spNum;
    bd2 = bd2+spNum;
    
    %% contact two images
    % 所有的边界节点彼此相连
    for ii = 1:length(bd1)
        edgesindext1{bd1(ii)}.indext = [edgesindext1{bd1(ii)}.indext,bd2];
    end
    % 原始图像目标区域与相似图像目标区域相连
    oriobject = []; %原始图像目标区域节点集合
    for a1 = 1:spNum
        ind1 = find(idxImg==a1);
        salmap = mat2gray(data{d}.sfusion_salmap);
        spsal1 = mean(salmap(ind1));
        if spsal1 > mean(salmap)
            oriobject = [oriobject,a1];
        end
    end
    if isempty(oriobject)
        for a4= 1:spNums
        ind4 = find(idxImgs==a4);
        spsal4 = mean(data{imlabel}.gt(ind4));
        if spsal4 > 0
            oriobject = [oriobject,a4];
        end
        end 
    end
    simobject = []; %相似图像目标区域节点集合
    for a2= 1:spNums
        ind2 = find(idxImgs==a2);
        spsal2 = mean(data{imlabel}.gt(ind2));
        if spsal2 > 0.5
            simobject = [simobject,a2];
        end
    end 
    if isempty(simobject)
        for a3= 1:spNums
        ind3 = find(idxImgs==a3);
        spsal3 = mean(data{imlabel}.gt(ind3));
        if spsal3 > 0
            simobject = [simobject,a3];
        end
        end 
    end
    simobject = simobject+spNum;
    for iii = 1:length(oriobject)
        edgesindext1{oriobject(iii)}.indext = [edgesindext1{oriobject(iii)}.indext,simobject];
    end
    
    %% get edges
    edges = [];
    for j = 1:spNum
        indext = edgesindext1{j}.indext;
        if(~isempty(indext))  %判断矩阵indext是否为空，为空则为0，否则为1。
            ed = ones(length(indext),2);  
            ed(:,2) = j*ed(:,2); %第二列是当前节点的标签
            ed(:,1) = indext; %第一列是与第二列有关联的所有节点
            edges = [edges;ed]; %竖向加入同一列，最终是两列向量。
        end
    end    
    edges = [edges;edges2];
    
    %% compute affinity matrix(eq. 4 in paper)
    seg_vals = [lab_val;lab_vals];
    theta =10; % control the edge weight 相当于公式中的1/σ2，其中σ2=0.1
    N = spNum+spNums;
    weights = makeweights(edges,seg_vals,theta);  %公式（4）。
    W = adjacency(edges,weights,N); %生成矩阵。
    
    %% learn the optimal affinity matrix (eq. 3 in paper)
    alpha=0.99;% control the balance of two items in manifold ranking cost function
    dd = sum(W);
    D = sparse(1:N,1:N,dd); 
    clear dd;
    optAff =(D-alpha*W)\eye(N);   %eye(spnum)产生spnum*spnum的单位矩阵
    mz=diag(ones(N,1));
    mz=~mz;
    optAff=optAff.*mz;
    
    %% compute the saliency value for each superpixel
    Y = zeros(N,1);
    Y(simobject) = 1;
    fsal=optAff*Y;    
    
    %% assign the saliency value to each pixel
    [m,n,l] = size(data{d}.im);
    tmap = zeros(m,n);
    for jj = 1:spNum
        indjj = find(idxImg==jj);
        tmap(indjj) = fsal(jj);    
    end
    tmap = (tmap-min(tmap(:)))/(max(tmap(:))-min(tmap(:)));
    co_sal{i}.tmap = tmap;
end   
co_salmap = 0;
for k = 1:similarnum
    label = ranklist(d,k);
    co_salmap = co_salmap+(1/Dist_im(d,label))*co_sal{k}.tmap;
end
co_salmap = (co_salmap-min(co_salmap(:)))/(max(co_salmap(:))-min(co_salmap(:)));
%% Graphcut_Refine
segmentation = graphCut_Refine10(data{d}.im,co_salmap);
co_salmap = co_salmap+segmentation;
co_salmap = (co_salmap-min(co_salmap(:)))/(max(co_salmap(:))-min(co_salmap(:)));
clear spNum spNums pixelList pixelLists idxImg idxImgs
