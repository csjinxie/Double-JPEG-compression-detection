function feature = feature_divfnew(coefs, qt, st1, st2)

%参数设置
dim=15;
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
pxl_err = abs(pxl-double(uint8(pxl)));
% 确定系数变化的块位置
change_pos = blkproc(coefs_err, [8,8], @find_change);
change_sum = sum(change_pos(:));
% 确定截断发生的块位置
trunc_pos = blkproc(pxl_err, [8,8], @find_trunc);
% 确定交流成分总量大于阈值st的块位置（小于阈值认为是平滑块）
ac_amp = blkproc(abs(coefs_dq), [8,8], @ac_ampsum);
ac_max = blkproc(abs(coefs_dq), [8,8], @ac_maxsum);
smooth_pos = ac_amp <= st1;
edge_pos =  ac_max >= st2 ;%阈值有待进一步考证

% 确定既发生系数变化，又发生截断的块位置
trunc_change = change_pos.*trunc_pos; 
nontrunc_change = change_pos.*(~trunc_pos);
smooth_change = change_pos.*smooth_pos;
edge_change = change_pos.*edge_pos;
else_change = change_pos.*(~smooth_pos).*(~edge_pos);
%确定交流变化的位置
ac_pos = blkproc(coefs_err_dq, [8,8], @find_ac);
% 特征提取
feature = zeros(1,dim);
% 1 截断概率特征与能量特征
feature(1) = sum(trunc_change(:)) / change_sum; % 截断变化块占变化块的比例
feature(2) = mean(pxl_err(trunc_change==1));%空域截断变化块误差的平均误差
feature(3) = mean(pxl_err(nontrunc_change==1));%空域非截断变化块误差的平均误差
feature(4) = mean(coefs_err_dq(trunc_change==1));%频域截断变化块的平均误差
feature(5) = mean(coefs_err_dq(nontrunc_change==1));%频域非截断变化块的平均误差
% 2 平滑概率特征与能量特征
feature(6) = sum(smooth_change(:)) / change_sum; % 平滑变化块占变化块的比例
feature(7) = sum(edge_change(:)) / change_sum; % 强边缘变化块占变化块比例
feature(8) = mean(pxl_err(smooth_change==1));%空域平滑变化块的平均误差
feature(9) = mean(pxl_err(edge_change==1));%空域强边缘变化块的平均误差
feature(10) = std2(pxl_err(else_change==1));%空域其它变化块的平均误差
feature(11) = mean(coefs_err_dq(smooth_change==1));%频域平滑变化块得平均误差
feature(12) = mean(coefs_err_dq(edge_change==1));%频域强边缘变化块得平均误差
feature(13) = mean(coefs_err_dq(else_change==1));%频域其它变化块得平均误差
% 空域的误差特征
% tcs = (trunc_change.*smooth_pos); 
% tcns = (trunc_change.*nonsmooth_pos); 
% ntcs = (nontrunc_change.*smooth_pos); 
% ntcns = (nontrunc_change.*nonsmooth_pos); 
% 
% tcs_pe = pxl_err(tcs==1);% 截断平滑块的空域平均误差
% tcns_pe = pxl_err(tcns==1);% 截断非平滑块的空域平均误差
% ntcs_pe = pxl_err(ntcs==1);% 非截断平滑块的空域平均误差
% ntcns_pe = pxl_err(ntcns==1);% 非截断非平滑块的空域平均误差
% feature(7) = mean(pxl_err(change_pos==1));% 空域变化块的平均误差
% feature(5) = mean(tcns_pe);
% feature(6) = mean(ntcs_pe);
% feature(7) = mean(ntcns_pe);

% 频域的误差特征
% tcs_ce = coefs_err_dq(tcs==1);
% tcns_ce = coefs_err_dq(tcns==1);
% ntcs_ce = coefs_err_dq(ntcs==1);
% ntcns_ce = coefs_err_dq(ntcns==1);
% feature(8) = mean(coefs_err_dq(:)); % 频域平均误差
% feature(9) = mean(tcns_ce);
% feature(10) = mean(ntcs_ce);
% feature(11) = mean(ntcns_ce);

% 交流误差特征
dc_err = blkproc(coefs_err_dq, [8,8], @dc_errfun);
dc_errsum = sum(dc_err(:));
ac_errsum = sum(coefs_err_dq(:))-dc_errsum;
%  pxl_dif = blkproc(uint8(pxl), [8,8], @pxl_diffun);
dc_pos = blkproc(coefs_err_dq, [8,8], @find_dc);
%  pxl_difsum = sum(pxl_dif(:) .* ac_pos(:));
% pxl_average = sum(double(uint8(pxl(:)))/255 .* dc_pos(:))/64;
dc_sum = sum(abs(coefs_dq(:)).*dc_pos(:));
ac_sum = sum(abs(coefs_dq(:)).*ac_pos(:));
feature(14) = ac_errsum / ac_sum;

feature(15) = dc_errsum / dc_sum;

% 消除NaN
feature(isnan(feature)) = 0;
return;

% ============================ Subfunction.1 ==============================
function position = find_change(mtx)
position = false(size(mtx));
if sum(mtx(:)~=0)
    position(:) = 1;
end
return;
% ============================ Subfunction.2 ==============================
function position = find_trunc(mtx)
position = false(size(mtx));
if max(mtx(:))>0.5
    position(:) = 1;
end
return;
% ============================ Subfunction.3 ==============================
function ampsum = ac_ampsum(mtx)
ampsum = zeros(size(mtx));
ampsum(:) = sum(mtx(:)) - mtx(1,1);
return;
% ============================ Subfunction.4 ==============================
function acmax = ac_maxsum(mtx)
acmax = zeros(size(mtx));
mtx(1,1)=0;
acmax(:) = max(mtx(:));
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
% ============================ Subfunction.6 ==============================
function dcerr = dc_errfun(mtx)
dcerr = zeros(size(mtx));
dcerr(1,1) = mtx(1,1);
return;
% ============================ Subfunction.7 ==============================
function position = find_dc(mtx)
position = false(size(mtx));
if mtx(1,1)~=0
    position(1,1) = 1;
end
return;
% ============================ Subfunction.8 ==============================
function position = find_ac(mtx)
position = false(size(mtx));
mtx(1,1) = 0;
if nnz(mtx)~=0
    position(:) = 1;
    position(1,1) =0;
end
return;