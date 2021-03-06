clear; close all; clc;
%% image stitching based on alpha blending
% last modified on 5/8/2014
% by Lei Tian,(lei_tian@alum.mit.edu)

numlit = 1;
Nused = 293;
%% basic parameters for reconstruction
Np = 560;
overlap_data = 160;
ns1 = 1:Np-overlap_data:2160; ns1 = ns1(1:end-1);
ns2 = 1:Np-overlap_data:2560; ns2 = ns2(1:end-1);

out_dir = ['Res-patch-1-1-1LED-Result-bfbg'];
fn = [out_dir,'\RandLit-1-293'];
load(fn);

Nobj = size(O,1);
UpFactor = Nobj/Np;
overlap_O = UpFactor*overlap_data;

n1 = length(ns1)*(Nobj-overlap_O)+overlap_O;
n2 = length(ns2)*(Nobj-overlap_O)+overlap_O;

%% start stitching
obj_stitch = zeros(n1,n2);

% center
for m = 2:length(ns1)-1
    for n = 2:length(ns2)-1
        %% load in file
        out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
            num2str(numlit),'LED-Result-bfbg'];
        fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
        load(fn);
        %% process edge pixels by alpha blending
        O1 = O;
        for ll = 1:overlap_O
            O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
            O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
            O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
            O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
        end
        
        O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
            (n-1)*(Nobj-overlap_O)],'pre'),...
            [(length(ns1)-m)*(Nobj-overlap_O),...
            (length(ns2)-n)*(Nobj-overlap_O)],'post');
        
        obj_stitch = obj_stitch+O_tmp;
    end
end

%% top
for n = 2:length(ns2)-1
    m = 1;
    % load in file
    out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    O1 = O;
    for ll = 1:overlap_O
        O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
        %         O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
        O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
        O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
    end
    
    O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
        (n-1)*(Nobj-overlap_O)],'pre'),...
        [(length(ns1)-m)*(Nobj-overlap_O),...
        (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    obj_stitch = obj_stitch+O_tmp;
    
end
%% bottom
for n = 2:length(ns2)-1
    m = length(ns1);
    % load in file
    out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    O1 = O;
    for ll = 1:overlap_O
        %         O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
        O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
        O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
        O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
    end
    
    O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
        (n-1)*(Nobj-overlap_O)],'pre'),...
        [(length(ns1)-m)*(Nobj-overlap_O),...
        (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    obj_stitch = obj_stitch+O_tmp;
    
end
%% left
for m = 2:length(ns1)-1
    n = 1;
    % load in file
    out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    O1 = O;
    for ll = 1:overlap_O
        O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
        O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
        %         O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
        O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
    end
    
    O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
        (n-1)*(Nobj-overlap_O)],'pre'),...
        [(length(ns1)-m)*(Nobj-overlap_O),...
        (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    obj_stitch = obj_stitch+O_tmp;
    
end
%% right
for m = 2:length(ns1)-1
    n = length(ns2);
    % load in file
    out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
        num2str(numlit),'LED-Result-bfbg'];
    fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
    load(fn);
    
    % process edge pixels by alpha blending
    O1 = O;
    for ll = 1:overlap_O
        O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
        O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
        O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
        %         O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
    end
    
    O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
        (n-1)*(Nobj-overlap_O)],'pre'),...
        [(length(ns1)-m)*(Nobj-overlap_O),...
        (length(ns2)-n)*(Nobj-overlap_O)],'post');
    
    obj_stitch = obj_stitch+O_tmp;
    
end
%% Top left
m = 1; n = 1;
% load in file
out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
O1 = O;
for ll = 1:overlap_O
    O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
    %     O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
    %     O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
    O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
end

O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    (n-1)*(Nobj-overlap_O)],'pre'),...
    [(length(ns1)-m)*(Nobj-overlap_O),...
    (length(ns2)-n)*(Nobj-overlap_O)],'post');

obj_stitch = obj_stitch+O_tmp;
%% Top right
m = 1; n = length(ns2);
% load in file
out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
O1 = O;
for ll = 1:overlap_O
    O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
    %         O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
    O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
    %     O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
end

O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    (n-1)*(Nobj-overlap_O)],'pre'),...
    [(length(ns1)-m)*(Nobj-overlap_O),...
    (length(ns2)-n)*(Nobj-overlap_O)],'post');

obj_stitch = obj_stitch+O_tmp;
%% Bottom left
m = length(ns1); n = 1;
% load in file
out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
O1 = O;
for ll = 1:overlap_O
    %     O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
    O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
    %     O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
    O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
end

O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    (n-1)*(Nobj-overlap_O)],'pre'),...
    [(length(ns1)-m)*(Nobj-overlap_O),...
    (length(ns2)-n)*(Nobj-overlap_O)],'post');

obj_stitch = obj_stitch+O_tmp;
%% Bottom right
m = length(ns1); n = length(ns2);
% load in file
out_dir = ['.\Res-patch-',num2str(ns1(m)),'-',num2str(ns2(n)),'-',...
    num2str(numlit),'LED-Result-bfbg'];
fn = [out_dir,'\RandLit-',num2str(numlit),'-',num2str(Nused)];
load(fn);

% process edge pixels by alpha blending
O1 = O;
for ll = 1:overlap_O
    %     O1(end-ll+1,:) = O1(end-ll+1,:)*(ll-1)/overlap_O;
    O1(ll,:) = O1(ll,:)*(ll-1)/overlap_O;
    O1(:,ll) = O1(:,ll)*(ll-1)/overlap_O;
    %         O1(:,end-ll+1) = O1(:,end-ll+1)*(ll-1)/overlap_O;
end

O_tmp = padarray(padarray(O1,[(m-1)*(Nobj-overlap_O),...
    (n-1)*(Nobj-overlap_O)],'pre'),...
    [(length(ns1)-m)*(Nobj-overlap_O),...
    (length(ns2)-n)*(Nobj-overlap_O)],'post');

obj_stitch = obj_stitch+O_tmp;

save('obj_stitch','obj_stitch','-v7.3'); 

%%
ma = 6;
o = abs(obj_stitch);
o(o>ma)=ma;
o=uint8(o/ma*2^8);
figure; imshow(o)
imwrite(o,'ampl_fullFoV_1LED.tif');   
%%
ma_ph = 1.2;
mi_ph = -1.2;
op = -angle(obj_stitch);
op(op>ma_ph)=ma_ph;
op(op<mi_ph) = mi_ph;
op=uint8((op-mi_ph)/(ma_ph-mi_ph)*2^8);
figure; imshow(op)
imwrite(op,'ph_fullFoV_1LED.tif'); 
