%% As similar as possible saliency fusion
function [sfusion_salmap] = similar_fusion_cross(data,d,ranklist,Dist_im,similarnum)
x1 = 0;
x2 = 0;
x3 = 0;
x4 = 0;
x5 = 0;
x6 = 0;
for i = 1:similarnum
    label = ranklist(d,i);
    [m,n] = size(data{label}.gt);
    G = reshape(data{label}.gt,[m*n,1]);
    S1 = reshape(data{label}.sal1,[m*n,1]);
    S2 = reshape(data{label}.sal2,[m*n,1]);
    S3 = reshape(data{label}.sal3,[m*n,1]);
    S4 = reshape(data{label}.sal4,[m*n,1]);
    S5 = reshape(data{label}.sal5,[m*n,1]);
    S6 = reshape(data{label}.sal6,[m*n,1]);
    S = [S1,S2,S3,S4,S5,S6];
    H = S'*S;
    f = -S'*G;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
%     Aeq = [1,1,1,1,1,1];
%     beq = 1;
    lb = [0;0;0;0;0;0];
    ub = [];
%     ub = [1;1;1;1;1;1];
    x = quadprog(H,f,A,b,Aeq,beq,lb,ub);
%     x1 = x1+x(1,1);
%     x2 = x2+x(2,1);
%     x3 = x3+x(3,1);
%     x4 = x4+x(4,1);
%     x5 = x5+x(5,1);
%     x6 = x6+x(6,1);
    x1 = x1+(1/Dist_im(d,label))*x(1,1);
    x2 = x2+(1/Dist_im(d,label))*x(2,1);
    x3 = x3+(1/Dist_im(d,label))*x(3,1);
    x4 = x4+(1/Dist_im(d,label))*x(4,1);
    x5 = x5+(1/Dist_im(d,label))*x(5,1);
    x6 = x6+(1/Dist_im(d,label))*x(6,1);
end
sfusion_salmap = x1*data{d}.sal1+x2*data{d}.sal2+x3*data{d}.sal3+x4*data{d}.sal4+x5*data{d}.sal5+x6*data{d}.sal6;
sfusion_salmap = mat2gray(sfusion_salmap);  



