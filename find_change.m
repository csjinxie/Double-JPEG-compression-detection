% ============================ Subfunction.1 ==============================
function position = find_change(mtx)
position = false(size(mtx));
if sum(mtx(:)~=0)
    position(:) = 1;
end
return;