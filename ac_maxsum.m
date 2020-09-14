% ============================ Subfunction.4 ==============================
function acmax = ac_maxsum(mtx)
acmax = zeros(size(mtx));
mtx(1,1)=0;
acmax(:) = max(mtx(:));
return;