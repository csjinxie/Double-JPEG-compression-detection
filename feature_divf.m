function feature = feature_divf(coefs, QF, st)

% 对coefs进行重压缩
pxls_t = jpg_decps(coefs, QF);
coefs_t = jpg_cps(pxls_t, QF);
% 计算系数变化
coefs_err = abs(coefs - coefs_t);
% 计算反量化系数误差（频域）
qt = jpeg_qtable(QF);
coefs_dq = dequantize(coefs, qt);
coefs_err_dq = dequantize(coefs_err, qt);
% 计算反DCT像素误差（空域）
pxl = ibdct(coefs_dq)+128;
pxl_err = abs(pxl-double(uint8(pxl)));
% 确定系数变化的块位置
change_pos = blkproc(coefs_err, [8,8], @find_change);
% 确定截断发生的块位置
trunc_pos = blkproc(pxl_err, [8,8], @find_trunc);
% 确定交流成分总量大于阈值st的块位置（小于阈值认为是平滑块）
ac_amp = blkproc(abs(coefs_dq), [8,8], @ac_ampsum);
smooth_pos = ac_amp <= st*qt(1,1);

% 确定既发生系数变化，又发生截断的块位置
trunc_change = change_pos.*trunc_pos;
nontrunc_change = change_pos.*(~trunc_pos);
nonsmooth_pos = ~smooth_pos;
% 特征提取
feature = zeros(1,11);
% 1 概率特征
feature(1) = sum(trunc_change(:)) / sum(change_pos(:)); % 截断块占变化块的比例
feature(2) = sum(trunc_change(:).*smooth_pos(:)) / sum(trunc_change(:)); % 平滑块占截断块的比例
feature(3) = sum(nontrunc_change(:).*smooth_pos(:)) / sum(nontrunc_change(:)); % 平滑块占非截断块的比例
% 空域的误差特征
tcs = (trunc_change.*smooth_pos); 
tcns = (trunc_change.*nonsmooth_pos); 
ntcs = (nontrunc_change.*smooth_pos); 
ntcns = (nontrunc_change.*nonsmooth_pos); 

tcs_pe = pxl_err(tcs==1);% 截断平滑块的空域平均误差
tcns_pe = pxl_err(tcns==1);% 截断非平滑块的空域平均误差
ntcs_pe = pxl_err(ntcs==1);% 非截断平滑块的空域平均误差
ntcns_pe = pxl_err(ntcns==1);% 非截断非平滑块的空域平均误差
feature(4) = mean(tcs_pe);
feature(5) = mean(tcns_pe);
feature(6) = mean(ntcs_pe);
feature(7) = mean(ntcns_pe);

% 频域的误差特征
tcs_ce = coefs_err_dq(tcs==1);
tcns_ce = coefs_err_dq(tcns==1);
ntcs_ce = coefs_err_dq(ntcs==1);
ntcns_ce = coefs_err_dq(ntcns==1);
feature(8) = mean(tcs_ce); % 截断平滑块的频域平均误差
feature(9) = mean(tcns_ce);
feature(10) = mean(ntcs_ce);
feature(11) = mean(ntcns_ce);

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
if sum(mtx(:)>0.5)
    position(:) = 1;
end
return;
% ============================ Subfunction.3 ==============================
function ampsum = ac_ampsum(mtx)
ampsum = zeros(size(mtx));
ampsum(:) = sum(mtx(:)) - mtx(1,1);
return;
