%% gist+1/2(rgb+lab) 加权颜色直方图 卡方距离
function [ranklist,all_Dist] = retrieve_rank_cross(data,id,dataset1,dataset2,dataset3)
nn = min(10,size(data,1)-1);%10; %% first nn images
all_Dist = ones(size(data,1),size(data,1));
for i = 1:3
    data_test = eval(fullfile(['dataset',num2str(i)]));
    data_train = setdiff(id,data_test);
    test_num = size(data_test,2);
    train_num = size(data,1)-test_num;
    test_gist = zeros(512,test_num); %gist:512 dims
    train_gist = zeros(512,train_num);
    test_RGB_hist_sal = zeros(48,test_num);
    test_Lab_hist_sal = zeros(48,test_num);
    train_RGB_hist_gt = zeros(48,train_num);
    train_Lab_hist_gt = zeros(48,train_num);
    for m = 1:test_num
        test_gist(:,m) = (data{data_test(m)}.gist/sum(data{data_test(m)}.gist))';
        test_RGB_hist_sal(:,m) = data{data_test(m)}.RGB_hist_sal;
        test_Lab_hist_sal(:,m) = data{data_test(m)}.Lab_hist_sal;
    end
    for n = 1:train_num
        train_gist(:,n) = (data{data_train(n)}.gist/sum(data{data_train(n)}.gist))';
        train_RGB_hist_gt(:,n) = data{data_train(n)}.RGB_hist_gt;
        train_Lab_hist_gt(:,n) = data{data_train(n)}.Lab_hist_gt;
    end
    Dist_gist = vl_alldist2(train_gist,test_gist,'CHI2')*0.5;
    Dist_RGB = vl_alldist2(train_RGB_hist_gt,test_RGB_hist_sal,'CHI2')*0.5;
    Dist_Lab = vl_alldist2(train_Lab_hist_gt,test_Lab_hist_sal,'CHI2')*0.5;
    Dist_im = 0.5*(Dist_RGB+Dist_Lab)+Dist_gist;
    for p = 1:test_num
        for q = 1:train_num
            all_Dist(data_train(q),data_test(p)) = Dist_im(q,p);
        end
    end

end
   [all_Dist_rank,index]=sort(all_Dist,1,'ascend');
    index=index(1:nn,:)';
    all_Dist=all_Dist';
    query_results_gist_color=index;
    ranklist=query_results_gist_color;