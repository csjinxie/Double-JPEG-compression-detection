% ============================ Subfunction.2 ==============================
function trunc_max = find_trunc(mtx)
trunc_max = zeros(size(mtx));
trunc_max(:) = max(mtx(:));
return;