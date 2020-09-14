function [change_num,trunc_num] = block_change(coefs, qt)

% ��coefs������ѹ��
pxls_t = jpg_decps(coefs, qt);
coefs_t = jpg_cps(pxls_t, qt);

coef_diff = abs(coefs - coefs_t);

% ȷ��ϵ���仯��ͽضϱ仯���λ��
change_blk = blkproc(coef_diff, [8,8], @find_change1);
pxl_err = ibdct(dequantize(coefs,qt))+128 - double(pxls_t);
trunc_blk = blkproc(abs(pxl_err), [8,8], @find_trunc1);
trunc_blk = logical(change_blk & trunc_blk);
change_blk = logical(change_blk);


change_num = sum(change_blk(:)) / (4*7);
trunc_num = sum(trunc_blk(:)) / (4*7);