function pxls = jpg_decps(coefs, qt)
% JPEG Decompression
% coefs           quantized dct coefficient
% qt              quantization step table
% pxls            pixel matrix
coefs_dq = dequantize(coefs, qt);

pxls = ibdct(coefs_dq, 8);
pxls = pxls + 128;
pxls = uint8(pxls);
return;