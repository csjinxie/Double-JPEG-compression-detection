close all;
clear;
clc;

imgname = 'C:\Documents and Settings\Administrator\桌面\jpeg double compression detection\ucid4.bmp';
%imgname = 'C:\Documents and Settings\Administrator\桌面\jpeg double compression detection\NJIT1000\NJIT980.bmp';


QF = 70;

% JPEG 单次压缩
pxls = imread(imgname);
qtable = jpeg_qtable(QF);
coefs1 = jpg_cps(pxls, qtable);

 %figure(1);
 [coef_diff1,trunc_num1,change_num1,pxl_err1,dcterr_round1,dcterr_trunc1,coeff_diff_round1,coeff_diff_trunc1]=show_change(coefs1, qtable);
%  fun=@max;
%  a1=blkproc(coeff_diff_trunc1, [8 8], fun);
%  coeff_diff_mtrunc1=blkproc(a1', [8 8], fun);
%  b1=blkproc(coeff_diff_round1, [8 8], fun);
%  coeff_diff_mround1=blkproc(b1', [8 8], fun);
%  c1=blkproc(abs(dcterr_trunc1), [8 8], fun);
%  dcterr_mtrunc1=blkproc(c1', [8 8], fun);
%  d1=blkproc(abs(dcterr_round1), [8 8], fun);
%  dcterr_mround1=blkproc(d1', [8 8], fun);
 
 
 
 


% JPEG 双重压缩
pxls2 = jpg_decps(coefs1, qtable);
coefs2 = jpg_cps(pxls2, qtable);
%figure(2);
[coef_diff2,trunc_num2,change_num2,pxl_err2,dcterr_round2,dcterr_trunc2,coeff_diff_round2,coeff_diff_trunc2]=show_change(coefs2, qtable);










