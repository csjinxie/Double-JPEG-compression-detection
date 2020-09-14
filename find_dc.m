% ============================ Subfunction.7 ==============================
function position = find_dc(mtx)
position = false(size(mtx));
if mtx(1,1)~=0
    position(1,1) = 1;
end
return;