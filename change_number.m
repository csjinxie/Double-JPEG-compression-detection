close all;
clear all;
clc;
% ========== 参数设置 =========
QF = 70;
% =============================

code_dir = uigetdir(cd, '选择要添加到Matlab搜索路径的代码目录：');
addpath(code_dir);
%addpath([code_dir, '\jpegtbx_1.4']);
%addpath([code_dir, '\libsvm']);
bmp_dir = uigetdir(code_dir, '选择TIF图像目录：');

cd(bmp_dir);
imgs = dir('*.bmp');
imgNum = length(imgs);
imgNames = {imgs.name};

qt = jpeg_qtable(QF);
change_jpg1 = zeros(imgNum, 2);
change_jpg2 = zeros(imgNum, 2);

for i = 1 : imgNum
    cd(bmp_dir);
    bmp_pxl1 = imread(imgNames{i});
    %bmp_pxl=rgb2gray(bmp_pxl1);
    bmp_pxl=bmp_pxl1;
    % 单次压缩->特征提取
    jpg1_coef = jpg_cps(bmp_pxl, qt);
    %feature_jpg1(i,:) = feature_extraction(jpg1_coef, QF, qt, smooth_thres, edge_thres);
    [change_jpg1(i,1),change_jpg1(i,2)] = block_change(jpg1_coef,qt);
    % 显示改变系数的块
%     show_change(jpg1_coef, qt);
    % 双重压缩->特征提取
    jpg1_pxl = jpg_decps(jpg1_coef, qt);
    jpg2_coef = jpg_cps(jpg1_pxl, qt);
    %feature_jpg2(i,:) = feature_extraction(jpg2_coef, QF, qt, smooth_thres, edge_thres);
    [change_jpg2(i,1),change_jpg2(i,2)] = block_change(jpg2_coef,qt);
    % 显示改变系数的块
%     show_change(jpg2_coef, qt);
    sprintf('processingnums=%d',i)
end