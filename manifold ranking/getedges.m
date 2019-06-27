function [edgesindext,edges,bd] = getedges(superpixels,spnum)
[adjloop,bd] = AdjcProcloop(superpixels,spnum);  %计算邻接矩阵spnum*spnum，表示节点之间的相邻关系。
edgesindext = cell(spnum,1); %记录每个超像素节点连接的节点标签
edges=[];  %将矩阵edges设置为一个空矩阵，什么元素也没有
for i = 1:spnum
    indext = [];
    ind = find(adjloop(i,:)==1); %找到与超像素节点i有连接的其他所有节点位置，在这里位置也就是那个节点的标签，是一个行向量。
    for j = 1:length(ind)
        indj = find(adjloop(ind(j),:)==1); %找到与（超像素节点i连接的所有节点）有连接的节点位置，是一个行向量。
        indext = [indext,indj]; %横向加入同一行，最终是一个包含所有间接连接节点的行向量。
    end
    indext = [indext,ind]; 
    indext = indext((indext>i)); %只保留比本身标签值大的，避免重复。
    indext = unique(indext);  %unique取集合中不重复元素构成向量，避免重复。
    edgesindext{i}.indext = indext;
    if(~isempty(indext))  %判断矩阵indext是否为空，为空则为0，否则为1。
        ed = ones(length(indext),2);  
        ed(:,2) = i*ed(:,2); %第二列是当前节点的标签
        ed(:,1) = indext; %第一列是与第二列有关联的所有节点
        edges = [edges;ed]; %竖向加入同一列，最终是两列向量。
    end
end