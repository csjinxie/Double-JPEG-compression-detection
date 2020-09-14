function [coef_diff,trunc_num,change_num,pxl_err,dcterr_round,dcterr_trunc,coeff_diff_round,coeff_diff_trunc] = show_change(coefs, qt)

% 对coefs进行重压缩
pxls_t = jpg_decps(coefs, qt);
coefs_t = jpg_cps(pxls_t, qt);

coef_diff = abs(coefs - coefs_t);

% 确定系数变化块和截断变化块的位置
change_blk = blkproc(coef_diff, [8,8], @find_change1);
pxl_err = ibdct(dequantize(coefs,qt))+128 - double(pxls_t);
dct_err=bdct(pxl_err);
trunc_blk = blkproc(abs(pxl_err), [8,8], @find_trunc1);
trunc_blk_max = blkproc(abs(pxl_err), [8,8], @find_trunc);
trunc_blk_all =trunc_blk_max > 0.5;
dcterr_trunc=dct_err.*logical(trunc_blk_all);
rounding_blk_all = logical(~trunc_blk_all);
dcterr_round=dct_err.*rounding_blk_all;
trunc_blk = logical(change_blk & trunc_blk);
change_blk = logical(change_blk);
coeff_diff_round=coef_diff.*rounding_blk_all;
coeff_diff_trunc=coef_diff.*logical(trunc_blk_all);


change_num = sum(change_blk(:)) / (4*7);
trunc_num = sum(trunc_blk(:)) / (4*7);

% % 显示
% [r,c] = size(coefs);
% label_map = uint8(zeros(r,c,3));
% % 系数变化块标记为红色
% tmp1 = pxls_t;
% tmp1(change_blk) = 255;
% label_map(:,:,1) = tmp1;
% tmp2 = pxls_t;
% tmp2(change_blk) = 0;
% label_map(:,:,2) = tmp2;
% tmp3 = pxls_t;
% tmp3(change_blk) = 0;
% label_map(:,:,3) = tmp3;
% 
% % 发生截断块标记为绿色
% tmp1(trunc_blk) = 0;
% label_map(:,:,1) = tmp1;
% tmp2(trunc_blk) = 255;
% label_map(:,:,2) = tmp2;
% tmp3(trunc_blk) = 0;
% label_map(:,:,3) = tmp3;
% 
% imshow(label_map);
% disp_message = sprintf('变化块数量：%d, (Green)截断变化块数量：%d, %d/%d=%.2f', change_num,trunc_num, trunc_num, change_num, trunc_num/change_num);
% title(disp_message);
return;

