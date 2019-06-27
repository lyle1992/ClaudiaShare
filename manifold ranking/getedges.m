function [edgesindext,edges,bd] = getedges(superpixels,spnum)
[adjloop,bd] = AdjcProcloop(superpixels,spnum);  %�����ڽӾ���spnum*spnum����ʾ�ڵ�֮������ڹ�ϵ��
edgesindext = cell(spnum,1); %��¼ÿ�������ؽڵ����ӵĽڵ��ǩ
edges=[];  %������edges����Ϊһ���վ���ʲôԪ��Ҳû��
for i = 1:spnum
    indext = [];
    ind = find(adjloop(i,:)==1); %�ҵ��볬���ؽڵ�i�����ӵ��������нڵ�λ�ã�������λ��Ҳ�����Ǹ��ڵ�ı�ǩ����һ����������
    for j = 1:length(ind)
        indj = find(adjloop(ind(j),:)==1); %�ҵ��루�����ؽڵ�i���ӵ����нڵ㣩�����ӵĽڵ�λ�ã���һ����������
        indext = [indext,indj]; %�������ͬһ�У�������һ���������м�����ӽڵ����������
    end
    indext = [indext,ind]; 
    indext = indext((indext>i)); %ֻ�����ȱ����ǩֵ��ģ������ظ���
    indext = unique(indext);  %uniqueȡ�����в��ظ�Ԫ�ع��������������ظ���
    edgesindext{i}.indext = indext;
    if(~isempty(indext))  %�жϾ���indext�Ƿ�Ϊ�գ�Ϊ����Ϊ0������Ϊ1��
        ed = ones(length(indext),2);  
        ed(:,2) = i*ed(:,2); %�ڶ����ǵ�ǰ�ڵ�ı�ǩ
        ed(:,1) = indext; %��һ������ڶ����й��������нڵ�
        edges = [edges;ed]; %�������ͬһ�У�����������������
    end
end