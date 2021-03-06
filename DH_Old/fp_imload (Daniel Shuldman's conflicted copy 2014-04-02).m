%% Fresnel Propagation Image Loader Function.
% Loads an image that can be read into the Fresnel Propagator.
% Version 3.0


function [E0] = fp_imload(objectfile,background)
if nargin < 2
    background = 1;
else
    [~,~,ext]=fileparts(background);
    if strcmp(ext,'.mat')==1
        varnam=who('-file',background);
        background=load(background,varnam{1});
        background=background.(varnam{1});
    else
        background=double(imread(background));
    end
end
E0=(double(imread(objectfile))./background);

%
%% Finds center of image and crops to first radix2 (2048)
%comment this whole section out if not needed
[m,n]=size(E0);
center=round(size(E0)/2);
%radix2=2^(nextpow2(min(m,n))-1); %(2048)
radix2=2^(nextpow2(min(m,n))-2); %(1024)
%radix2=2^(nextpow2(min(m,n))-3); %(512)

%Center,Center
E0=E0((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
%Top,Center
%E0=E0(1:radix2,(center(2)+1-radix2/2):(center(2)+radix2/2));
%Bottom,Center
%E0=E0(end-radix2+1:end,(center(2)+1-radix2/2):(center(2)+radix2/2));
%vortmag01.tif
%E0=E0(1800-1023:1800,(center(2)+1-radix2/2)+70:(center(2)-70+radix2/2));
%vort01_0001.tif, vort02, vort04,
%E0=E0(250:250+1023,600:600+1023);
%vort03_0001.tif, vort05, vort06
%E0=E0(250:250+1023,900:900+1023);
%vort07_0001.tif
%E0=E0(250:250+1023,700:700+1023);
%vort10_0001.tif
%E0=E0(end-1023:end,1500-512:1500+511);
%vort12_0001.tif
%E0=E0(550:550+1023,1400-512:1400+511);
%vort13_0001.tif
%E0=E0(1300-1023:1300,1:2048);
%vorteating_0001.tif
%E0=E0(1500-1023:1500,500:500+1023);
%vorteating_0301.tif
%E0=E0(1500-1023:1500,1:1024);
%E0=E0(1500-1023:1500,257:1024-256); %tall rectangle
%E0=E0(1500-1023+512:1500,1024-511-150:1024-150); %small 512 square
%Custom,Center
%E0=E0(1500-1023:1600,(center(2)+1-radix2/2):(center(2)+radix2/2));
%

%{
%% Finds top of image and crops to second radix2 (1024)
%comment this whole section out if not needed
[m,n]=size(E0);
center=round(size(E0)/2);
radix2=2^(nextpow2(min(m,n))-2);
%Top,Center
E0=E0(1:radix2,(center(2)+1-radix2/2):(center(2)+radix2/2));
%}