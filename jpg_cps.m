function coefs = jpg_cps(pxls, qt)

% JPEG Compression
% pxl      pixel matirx
% qt       quantization step table
% coefs    quantized dct coefficients
pxls = double(pxls);
pxls = pxls - 128;

coefs_uq = bdct(pxls, 8);

coefs = quantize(coefs_uq, qt);
return;

