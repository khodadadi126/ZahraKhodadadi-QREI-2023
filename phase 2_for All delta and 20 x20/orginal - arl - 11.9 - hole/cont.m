close all
clear
clc
%I=imread('peppers.png');
%size(I)
%I=imread('Nonwoven.png');
%I=imread('Nonwoven.png');
I=imread('Tile_Nom.png');
I=imresize(I,[512,512]);
% I=I(1:250,1:  250 ,:)  ;
%imshow(I);
%I=imread('lena.png');
%I=rgb2gray(I);
figure,imshow(I);
%title('Original Peppers image');

pfilter='pkva';
dfilter='pkva';
nlevels=[1 2];


y = pdfbdec(double(I),pfilter, dfilter, nlevels);

figure
ContourletCoeff=showpdfb(y);
New=ContourletCoeff.New;
%figure
%a=image( New );
%axis  off;
%axis image ;
%save('behrouz',a)

















title('The Contoutlet Decompostion of Peppers image');