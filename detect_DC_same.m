close all;
clear all;
clc;
% ========== 参数设置 =========
QF = 95;
dim = 13;
% svm 参数选择范围
C_exps = 0:20;  
r_exps = -15:3;
% 输出文件
report_file = 'report.txt';
% =============================

code_dir = uigetdir(cd, '选择要添加到Matlab搜索路径的代码目录：');
addpath(code_dir);
%addpath([code_dir, '\jpegtbx_1.4']);
%addpath([code_dir, '\libsvm']);
bmp_dir = uigetdir(code_dir, '选择TIF图像目录：');

cd(bmp_dir);
imgs = dir('*.tif');
imgNum = length(imgs);
imgNames = {imgs.name};

qt = jpeg_qtable(QF);

feature_jpg1 = zeros(imgNum, dim);
feature_jpg2 = zeros(imgNum, dim);
for i = 1 : imgNum
    cd(bmp_dir);
    bmp_pxl1 = imread(imgNames{i});
    bmp_pxl=rgb2gray(bmp_pxl1);
    %bmp_pxl=bmp_pxl1;
    % 单次压缩->特征提取
    jpg1_coef = jpg_cps(bmp_pxl, qt);
    %feature_jpg1(i,:) = feature_extraction(jpg1_coef, QF, qt, smooth_thres, edge_thres);
    feature_jpg1(i,:) = feature_extraction1(jpg1_coef,qt);
    % 显示改变系数的块
%     show_change(jpg1_coef, qt);
    % 双重压缩->特征提取
    jpg1_pxl = jpg_decps(jpg1_coef, qt);
    jpg2_coef = jpg_cps(jpg1_pxl, qt);
    %feature_jpg2(i,:) = feature_extraction(jpg2_coef, QF, qt, smooth_thres, edge_thres);
    feature_jpg2(i,:) = feature_extraction1(jpg2_coef,qt);
    % 显示改变系数的块
%     show_change(jpg2_coef, qt);
    sprintf('processingnums=%d',i)
end

% SVM 分类
% scale data
rands=randperm(1338);
feature11=feature_jpg1(rands,:);
feature22=feature_jpg2(rands,:);
label_vec = [zeros(imgNum,1); ones(imgNum,1)];
%feature_mtx  = [feature_jpg1; feature_jpg2];
feature_mtx  = [feature11; feature22];
feature_mtx = scale_data(feature_mtx);
% % 保存特征数据
% cd(bmp_dir);
% feature_mtx = sparse(feature_mtx);
% libsvmwrite('jpg_feature.txt', label_vec, feature_mtx);
% % 交叉校验
% [label_vec, feature_mtx] = libsvmread('jpg_feature.txt');
% feature_mtx = full(feature_mtx);

C_num = length(C_exps);
r_num = length(r_exps);
acr = zeros(C_num, r_num);
for i = 1 : C_num
    for j = 1 : r_num
        C = 2^C_exps(i);
        r = 2^r_exps(j);
        acr(i,j) = svmtrain(label_vec, feature_mtx, ...
                ['-c ' num2str(C) ' -g ' num2str(r), ' -q' ,' -v ' num2str(2), ' -m ' num2str(500), ' -e ' num2str(0.1)]);
    end
end

% 输出结果
acr_best = max(acr(:));
[bi,bj] = find(acr_best==acr);

% %训练模型，预测结果
% model = svmtrain(label_vec, feature_mtx, ...
%                 ['-c ' num2str(C) ' -g ' num2str(r), ' -q', ' -e ' num2str(0.1)]);
% [predict_label, accuracy, prob_estimates] = svmpredict(label_vec, feature_mtx, model);

% fid = fopen(report_file, 'a+');
% fprintf(fid, 'best accuracy of calssification: %.2f', acr_best);
% fprintf(fid, '\ncorresponding C and r: %.4f,  %.4f', C_exps(bi(1)), r_exps(bj(1)));
% fclose(fid);






