function feature = feature_extraction(coefs, QF, qt, st1, st2)

%参数设置
dim=29;
if QF>=90
    tr1=4;tr2=8;
elseif QF>=80
    tr1=8;tr2=15;
else
    tr1=10;tr2=20;
end
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
trunc_pos1 = trunc_max <= tr1;
trunc_pos3 = trunc_max > tr2;
trunc_pos2 = logical((trunc_max > tr1).*(trunc_max <= tr2));
    
% 确定交流成分总量大于阈值st的块位置（小于阈值认为是平滑块）
ac_amp = blkproc(abs(coefs), [8,8], @ac_ampsum);
ac_max = blkproc(abs(coefs), [8,8], @ac_maxsum);
smooth_pos = ac_amp <= st1;
edge_pos =  ac_max >= st2;%阈值有待进一步考证
bigcoef_pos = abs(coefs) >= st2;

% 确定既发生系数变化，又发生截断的块位置
smooth_change = logical(change_pos.*smooth_pos);
edge_change = logical(change_pos.*edge_pos);
else_change = logical(change_pos.*(~smooth_pos).*(~edge_pos));

edge_change_trunc1 = logical(edge_change.*(trunc_pos1==1));
edge_change_trunc2 = logical(edge_change.*(trunc_pos2==1));
edge_change_trunc3 = logical(edge_change.*(trunc_pos3==1));

else_change_trunc1 = logical(else_change.*(trunc_pos1==1));
else_change_trunc2 = logical(else_change.*(trunc_pos2==1));
else_change_trunc3 = logical(else_change.*(trunc_pos3==1));

%确定直流和交流变化的位置
ac_pos = blkproc(coefs_err_dq, [8,8], @find_ac);
dc_pos = blkproc(coefs_err_dq, [8,8], @find_dc);
% 特征提取
feature = zeros(1,dim);
% 直流特征
feature(1) = sum(dc_pos(:)) / change_sum; % 直流变化块占变化块的比例

% 交流特征:平滑块
feature(2) = sum(smooth_change(:)) / change_sum;%平滑变化快占变化块的比例
feature(3) = mean(abs(pxl_err(smooth_change==1)));%空域平滑变化块误差的均值
feature(4) = mean(coefs_err_dq(smooth_change==1));%频域平滑变化块的平均误差

% 交流特征:强边缘块
feature(5) = sum(coefs_err_dq(:).*bigcoef_pos(:)) / sum(coefs_err_dq(:));%大系数频域变化量占总变化量的比例
if isnan(feature(5))
    feature(5)=1;
end
feature(6) = mean(abs(pxl_err(edge_change_trunc1)));
feature(7) = mean(abs(pxl_err(edge_change_trunc2)));
feature(8) = mean(abs(pxl_err(edge_change_trunc3)));
feature(9) = var((pxl_err(edge_change_trunc1)));
feature(10) = var((pxl_err(edge_change_trunc2)));
feature(11) = var((pxl_err(edge_change_trunc3)));%空域误差特征


feature(12) = mean(coefs_err_dq(edge_change_trunc1));
feature(13) = mean(coefs_err_dq(edge_change_trunc2));
feature(14) = mean(coefs_err_dq(edge_change_trunc3));%频域变化块的平均误差
feature(15) = sum(coefs_err_dq(edge_change_trunc1.*ac_pos==1))/sum(abs(coefs_dq(edge_change_trunc1.*ac_pos==1)));
feature(16) = sum(coefs_err_dq(edge_change_trunc2.*ac_pos==1))/sum(abs(coefs_dq(edge_change_trunc2.*ac_pos==1)));
feature(17) = sum(coefs_err_dq(edge_change_trunc3.*ac_pos==1))/sum(abs(coefs_dq(edge_change_trunc3.*ac_pos==1)));
% 交流特征:其他块
feature(18) = mean(abs(pxl_err(else_change_trunc1)));
feature(19) = mean(abs(pxl_err(else_change_trunc2)));
feature(20) = mean(abs(pxl_err(else_change_trunc3)));
feature(21) = var((pxl_err(else_change_trunc1)));
feature(22) = var((pxl_err(else_change_trunc2)));
feature(23) = var((pxl_err(else_change_trunc3)));%空域误差特征

feature(24) = mean(coefs_err_dq(else_change_trunc1));
feature(25) = mean(coefs_err_dq(else_change_trunc2));
feature(26) = mean(coefs_err_dq(else_change_trunc3));%频域变化块得平均误差
feature(27) = sum(coefs_err_dq(else_change_trunc1.*ac_pos==1))/sum(abs(coefs_dq(else_change_trunc1.*ac_pos==1)));
feature(28) = sum(coefs_err_dq(else_change_trunc2.*ac_pos==1))/sum(abs(coefs_dq(else_change_trunc2.*ac_pos==1)));
feature(29) = sum(coefs_err_dq(else_change_trunc3.*ac_pos==1))/sum(abs(coefs_dq(else_change_trunc3.*ac_pos==1)));


% 消除NaN
feature(isnan(feature)) = 0;
return;





% ============================ Subfunction.5 ==============================
% function pxldif = pxl_diffun(mtx)
% pxldif = zeros(size(mtx));
% pxldif_r = zeros(size(mtx));
% pxldif_c = zeros(size(mtx));
% pxldif_r(:,1:7) = abs(mtx(:,1:7) - mtx(:,2:8));
% pxldif_c(1:7,:) = abs(mtx(1:7,:) - mtx(2:8,:));
% pxldif(:) = double(pxldif_r(:) + pxldif_c(:)) / 64;
% return;
% % ============================ Subfunction.6 ==============================
% function dcerr = dc_errfun(mtx)
% dcerr = zeros(size(mtx));
% dcerr(1,1) = mtx(1,1);
% return;


for i=1:29
    [a1,b1]=find(feature_jpg1(:,i)==0);
    nf1(i)=length(a1);
end
