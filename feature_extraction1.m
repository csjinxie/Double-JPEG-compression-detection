function feature = feature_extraction1(coefs,qt)

%参数设置
dim=13;
% if QF>=90
%     tr1=4;tr2=8;
% elseif QF>=80
%     tr1=8;tr2=15;
% else
%     tr1=10;tr2=20;
% end
% 对coefs进行重压缩
pxls_t = jpg_decps(coefs, qt);
coefs_t = jpg_cps(pxls_t, qt);
% 计算系数变化
coefs_err = abs(coefs - coefs_t);
% 计算反量化系数误差（频域）
coefs_dq = dequantize(coefs, qt);
coefs_err_dq = dequantize(coefs_err, qt);
% 计算反DCT像素误差（空域）
pxl = ibdct(coefs_dq)+128;
pxl_err = pxl-double(uint8(pxl));
% 确定系数变化的块位置
change_pos = blkproc(coefs_err, [8,8], @find_change);
change_sum = sum(change_pos(:));
% 确定截断发生的块位置(按截断误差大小分为三类)
trunc_max = blkproc(abs(pxl_err), [8,8], @find_trunc);
trunc_pos1 = trunc_max > 0.5;
nontrunc_pos1 = logical(change_pos.*(~trunc_pos1));
    
% % % 确定交流成分总量大于阈值st的块位置（小于阈值认为是平滑块）
% % ac_amp = blkproc(abs(coefs), [8,8], @ac_ampsum);
% % ac_max = blkproc(abs(coefs), [8,8], @ac_maxsum);
% % smooth_pos = ac_amp <= st1;
% % edge_pos =  ac_max >= st2;%阈值有待进一步考证
% % bigcoef_pos = abs(coefs) >= st2;


%确定直流和交流变化的位置
ac_pos = blkproc(coefs_err_dq, [8,8], @find_ac);
dc_pos = blkproc(coefs_err_dq, [8,8], @find_dc);
% 特征提取
feature = zeros(1,dim);
% 直流特征
feature(1) = sum(dc_pos(:))*64 / change_sum; % 直流变化块占变化块的比例
feature(2) = mean(abs(pxl_err(trunc_pos1==1)));
feature(3) = mean(coefs_err_dq(trunc_pos1==1));
feature(4) = var(abs(pxl_err(trunc_pos1==1)));
feature(5) = var(coefs_err_dq(trunc_pos1==1));
feature(6) = mean(abs(pxl_err(nontrunc_pos1==1)));
feature(7) = mean(coefs_err_dq(nontrunc_pos1==1));
feature(8) = var(abs(pxl_err(nontrunc_pos1==1)));
feature(9) = var(coefs_err_dq(nontrunc_pos1==1));
feature(10) = sum(coefs_err_dq(trunc_pos1.*ac_pos==1))/sum(abs(coefs_dq(trunc_pos1.*ac_pos==1)));
feature(11) = sum(coefs_err_dq(trunc_pos1.*dc_pos==1))/sum(abs(coefs_dq(trunc_pos1.*dc_pos==1)));
feature(12) = sum(coefs_err_dq(nontrunc_pos1.*ac_pos==1))/sum(abs(coefs_dq(nontrunc_pos1.*ac_pos==1)));
feature(13) = sum(coefs_err_dq(nontrunc_pos1.*dc_pos==1))/sum(abs(coefs_dq(nontrunc_pos1.*dc_pos==1)));

% feature(1) = sum(dc_pos(:))*64 / change_sum; % 直流变化块占变化块的比例
% feature(2) = mean(abs(pxl_err(change_pos==1)));
% feature(3) = mean(coefs_err_dq(change_pos==1));
% feature(4) = var(abs(pxl_err(change_pos==1)));
% feature(5) = var(coefs_err_dq(change_pos==1));
% feature(6) = sum(coefs_err_dq(change_pos.*ac_pos==1))/sum(abs(coefs_dq(change_pos.*ac_pos==1)));
% feature(7) = sum(coefs_err_dq(change_pos.*dc_pos==1))/sum(abs(coefs_dq(change_pos.*dc_pos==1)));

% 消除NaN
feature(isnan(feature)) = 0;
return;