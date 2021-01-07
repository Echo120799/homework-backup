
clc
clear

I=imread('lena.jpg');  %读入原始载体图像 

[row column]=size(I);             
Img_source=reshape(I,[],1);
L=length(Img_source);               %图像数据总数
blocksize=8;                        %分块尺寸
number_blocks=L/(blocksize^2);      %计算分块数

% 水印图像预处理
[message_pad]=copyright(number_blocks); 

%**** 水印信息的嵌入 
step=1;   %量化步长
s=32;     %模值

for y=0:(row/blocksize-1)
    for x=0:(column/blocksize-1)
        
        %分块进行DCT变换
        dct_block=dct2(I((y*blocksize+1):(y+1)*blocksize,(x*blocksize+1):(x+1)*blocksize));
        dct_block_WM=dct_block;  %备份变换后的DCT系数
        
        % DCT变换后以step为步长量化
        messured_dct_block=dct_block/step;  
        %将量化后系数以S取模值，并计算取模前后的差值
        relaxed_messured_dct_block=messured_dct_block-mod(messured_dct_block,s);            
             
        if (message_pad(y*column/blocksize+x+1) == 0)   % 如果水印序列为0 　
            dct_block_WM(1,1)=relaxed_messured_dct_block(1,1)+s/4;
            
        elseif (message_pad(y*column/blocksize+x+1) == 1)  %如果水印序列为1  
            dct_block_WM(1,1)=relaxed_messured_dct_block(1,1)+3*s/4;
        end
                
        % 将新的DCT系数进行逆DCT变换，转换到空域
            waterMarked( y*blocksize+1:(y+1)*blocksize,x*blocksize+1:(x+1)*blocksize)=idct2(dct_block_WM); 
            
    end
end

Img_W=uint8(waterMarked);   %数据类型转换
figure(2);
imshow(Img_W); 
title('嵌入水印后的图像');%显示嵌入水印后的图像
imwrite(Img_W,'DCTWm.bmp');  %保存嵌入水印后的图像

%计算PSNR
psnr=PSNR(Img_W,I),
ssim=SSIM(Img_W,I),
