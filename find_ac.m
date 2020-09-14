% ============================ Subfunction.8 ==============================
function position = find_ac(mtx)
position = false(size(mtx));
mtx(1,1) = 0;
if nnz(mtx)~=0
    position(:) = 1;
    position(1,1) =0;
end
return;