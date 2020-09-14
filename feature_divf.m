function feature = feature_divf(coefs, QF, st)

% ��coefs������ѹ��
pxls_t = jpg_decps(coefs, QF);
coefs_t = jpg_cps(pxls_t, QF);
% ����ϵ���仯
coefs_err = abs(coefs - coefs_t);
% ���㷴����ϵ����Ƶ��
qt = jpeg_qtable(QF);
coefs_dq = dequantize(coefs, qt);
coefs_err_dq = dequantize(coefs_err, qt);
% ���㷴DCT����������
pxl = ibdct(coefs_dq)+128;
pxl_err = abs(pxl-double(uint8(pxl)));
% ȷ��ϵ���仯�Ŀ�λ��
change_pos = blkproc(coefs_err, [8,8], @find_change);
% ȷ���ضϷ����Ŀ�λ��
trunc_pos = blkproc(pxl_err, [8,8], @find_trunc);
% ȷ�������ɷ�����������ֵst�Ŀ�λ�ã�С����ֵ��Ϊ��ƽ���飩
ac_amp = blkproc(abs(coefs_dq), [8,8], @ac_ampsum);
smooth_pos = ac_amp <= st*qt(1,1);

% ȷ���ȷ���ϵ���仯���ַ����ضϵĿ�λ��
trunc_change = change_pos.*trunc_pos;
nontrunc_change = change_pos.*(~trunc_pos);
nonsmooth_pos = ~smooth_pos;
% ������ȡ
feature = zeros(1,11);
% 1 ��������
feature(1) = sum(trunc_change(:)) / sum(change_pos(:)); % �ضϿ�ռ�仯��ı���
feature(2) = sum(trunc_change(:).*smooth_pos(:)) / sum(trunc_change(:)); % ƽ����ռ�ضϿ�ı���
feature(3) = sum(nontrunc_change(:).*smooth_pos(:)) / sum(nontrunc_change(:)); % ƽ����ռ�ǽضϿ�ı���
% ������������
tcs = (trunc_change.*smooth_pos); 
tcns = (trunc_change.*nonsmooth_pos); 
ntcs = (nontrunc_change.*smooth_pos); 
ntcns = (nontrunc_change.*nonsmooth_pos); 

tcs_pe = pxl_err(tcs==1);% �ض�ƽ����Ŀ���ƽ�����
tcns_pe = pxl_err(tcns==1);% �ضϷ�ƽ����Ŀ���ƽ�����
ntcs_pe = pxl_err(ntcs==1);% �ǽض�ƽ����Ŀ���ƽ�����
ntcns_pe = pxl_err(ntcns==1);% �ǽضϷ�ƽ����Ŀ���ƽ�����
feature(4) = mean(tcs_pe);
feature(5) = mean(tcns_pe);
feature(6) = mean(ntcs_pe);
feature(7) = mean(ntcns_pe);

% Ƶ����������
tcs_ce = coefs_err_dq(tcs==1);
tcns_ce = coefs_err_dq(tcns==1);
ntcs_ce = coefs_err_dq(ntcs==1);
ntcns_ce = coefs_err_dq(ntcns==1);
feature(8) = mean(tcs_ce); % �ض�ƽ�����Ƶ��ƽ�����
feature(9) = mean(tcns_ce);
feature(10) = mean(ntcs_ce);
feature(11) = mean(ntcns_ce);

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
if sum(mtx(:)>0.5)
    position(:) = 1;
end
return;
% ============================ Subfunction.3 ==============================
function ampsum = ac_ampsum(mtx)
ampsum = zeros(size(mtx));
ampsum(:) = sum(mtx(:)) - mtx(1,1);
return;
