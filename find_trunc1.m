% ============================ Subfunction.2 ==============================
function position = find_trunc(mtx)
position = false(size(mtx));
if sum(mtx(:)>0.5)
    position([1,end], :) = 1;
    position(:, [1,end]) = 1;
end
return;