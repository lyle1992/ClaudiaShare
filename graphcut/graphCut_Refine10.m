function [result] = graphCut_Refine10(image,smap)
lambdaPara = 10;
[h, w, dim] = size(image);
image = double(image);
% edge 连接
E = edges4connected(h,w);
% 平滑项
m1 = image(:,:,1);
m2 = image(:,:,2);
m3 = image(:,:,3); 
clear image
V = 1./(1+sqrt((m1(E(:,1))-m1(E(:,2))).^2+(m2(E(:,1))-m2(E(:,2))).^2+(m3(E(:,1))-m3(E(:,2))).^2));
AA = lambdaPara*sparse(E(:,1),E(:,2),0.3*V);
% 滤波器核
g = fspecial('gauss', [5 5], sqrt(5));  
% graph-cut
[result] = graphcut1(AA,g,smap);
result = normalizeSal(result);
clear image smap
end