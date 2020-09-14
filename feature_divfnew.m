function feature = feature_divfnew(coefs, qt, st1, st2)

%��������
dim=15;
% ��coefs������ѹ��
pxls_t = jpg_decps(coefs, qt);
coefs_t = jpg_cps(pxls_t, qt);
% ����ϵ���仯
coefs_err = abs(coefs - coefs_t);
% ���㷴����ϵ����Ƶ��
coefs_dq = dequantize(coefs, qt);
coefs_err_dq = dequantize(coefs_err, qt);
% ���㷴DCT����������
pxl = ibdct(coefs_dq)+128;
pxl_err = abs(pxl-double(uint8(pxl)));
% ȷ��ϵ���仯�Ŀ�λ��
change_pos = blkproc(coefs_err, [8,8], @find_change);
change_sum = sum(change_pos(:));
% ȷ���ضϷ����Ŀ�λ��
trunc_pos = blkproc(pxl_err, [8,8], @find_trunc);
% ȷ�������ɷ�����������ֵst�Ŀ�λ�ã�С����ֵ��Ϊ��ƽ���飩
ac_amp = blkproc(abs(coefs_dq), [8,8], @ac_ampsum);
ac_max = blkproc(abs(coefs_dq), [8,8], @ac_maxsum);
smooth_pos = ac_amp <= st1;
edge_pos =  ac_max >= st2 ;%��ֵ�д���һ����֤

% ȷ���ȷ���ϵ���仯���ַ����ضϵĿ�λ��
trunc_change = change_pos.*trunc_pos; 
nontrunc_change = change_pos.*(~trunc_pos);
smooth_change = change_pos.*smooth_pos;
edge_change = change_pos.*edge_pos;
else_change = change_pos.*(~smooth_pos).*(~edge_pos);
%ȷ�������仯��λ��
ac_pos = blkproc(coefs_err_dq, [8,8], @find_ac);
% ������ȡ
feature = zeros(1,dim);
% 1 �ضϸ�����������������
feature(1) = sum(trunc_change(:)) / change_sum; % �ضϱ仯��ռ�仯��ı���
feature(2) = mean(pxl_err(trunc_change==1));%����ضϱ仯������ƽ�����
feature(3) = mean(pxl_err(nontrunc_change==1));%����ǽضϱ仯������ƽ�����
feature(4) = mean(coefs_err_dq(trunc_change==1));%Ƶ��ضϱ仯���ƽ�����
feature(5) = mean(coefs_err_dq(nontrunc_change==1));%Ƶ��ǽضϱ仯���ƽ�����
% 2 ƽ��������������������
feature(6) = sum(smooth_change(:)) / change_sum; % ƽ���仯��ռ�仯��ı���
feature(7) = sum(edge_change(:)) / change_sum; % ǿ��Ե�仯��ռ�仯�����
feature(8) = mean(pxl_err(smooth_change==1));%����ƽ���仯���ƽ�����
feature(9) = mean(pxl_err(edge_change==1));%����ǿ��Ե�仯���ƽ�����
feature(10) = std2(pxl_err(else_change==1));%���������仯���ƽ�����
feature(11) = mean(coefs_err_dq(smooth_change==1));%Ƶ��ƽ���仯���ƽ�����
feature(12) = mean(coefs_err_dq(edge_change==1));%Ƶ��ǿ��Ե�仯���ƽ�����
feature(13) = mean(coefs_err_dq(else_change==1));%Ƶ�������仯���ƽ�����
% ������������
% tcs = (trunc_change.*smooth_pos); 
% tcns = (trunc_change.*nonsmooth_pos); 
% ntcs = (nontrunc_change.*smooth_pos); 
% ntcns = (nontrunc_change.*nonsmooth_pos); 
% 
% tcs_pe = pxl_err(tcs==1);% �ض�ƽ����Ŀ���ƽ�����
% tcns_pe = pxl_err(tcns==1);% �ضϷ�ƽ����Ŀ���ƽ�����
% ntcs_pe = pxl_err(ntcs==1);% �ǽض�ƽ����Ŀ���ƽ�����
% ntcns_pe = pxl_err(ntcns==1);% �ǽضϷ�ƽ����Ŀ���ƽ�����
% feature(7) = mean(pxl_err(change_pos==1));% ����仯���ƽ�����
% feature(5) = mean(tcns_pe);
% feature(6) = mean(ntcs_pe);
% feature(7) = mean(ntcns_pe);

% Ƶ����������
% tcs_ce = coefs_err_dq(tcs==1);
% tcns_ce = coefs_err_dq(tcns==1);
% ntcs_ce = coefs_err_dq(ntcs==1);
% ntcns_ce = coefs_err_dq(ntcns==1);
% feature(8) = mean(coefs_err_dq(:)); % Ƶ��ƽ�����
% feature(9) = mean(tcns_ce);
% feature(10) = mean(ntcs_ce);
% feature(11) = mean(ntcns_ce);

% �����������
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

% ����NaN
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