% ============================ Subfunction.3 ==============================
function ampsum = ac_ampsum(mtx)
ampsum = zeros(size(mtx));
ampsum(:) = sum(mtx(:)) - mtx(1,1);
return;