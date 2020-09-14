close all;
clear all;
clc;
% ========== �������� =========
QF = 70;
% =============================

code_dir = uigetdir(cd, 'ѡ��Ҫ��ӵ�Matlab����·���Ĵ���Ŀ¼��');
addpath(code_dir);
%addpath([code_dir, '\jpegtbx_1.4']);
%addpath([code_dir, '\libsvm']);
bmp_dir = uigetdir(code_dir, 'ѡ��TIFͼ��Ŀ¼��');

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
    % ����ѹ��->������ȡ
    jpg1_coef = jpg_cps(bmp_pxl, qt);
    %feature_jpg1(i,:) = feature_extraction(jpg1_coef, QF, qt, smooth_thres, edge_thres);
    [change_jpg1(i,1),change_jpg1(i,2)] = block_change(jpg1_coef,qt);
    % ��ʾ�ı�ϵ���Ŀ�
%     show_change(jpg1_coef, qt);
    % ˫��ѹ��->������ȡ
    jpg1_pxl = jpg_decps(jpg1_coef, qt);
    jpg2_coef = jpg_cps(jpg1_pxl, qt);
    %feature_jpg2(i,:) = feature_extraction(jpg2_coef, QF, qt, smooth_thres, edge_thres);
    [change_jpg2(i,1),change_jpg2(i,2)] = block_change(jpg2_coef,qt);
    % ��ʾ�ı�ϵ���Ŀ�
%     show_change(jpg2_coef, qt);
    sprintf('processingnums=%d',i)
end