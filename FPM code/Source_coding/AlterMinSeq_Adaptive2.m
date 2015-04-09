function [O, P, err, c_vec] = AlterMinSeq_Adaptive2( I, No, Ns, opts)
%AlterMinSeq Implement alternative minimization sequentially on a stack of
%measurement I (n1 x n2 x nz). It consists of 2 loop. The main loop update
%the reconstruction results r. the inner loop applies projectors/minimizers
%P1 and P2 on each image I and steps through the entire dataset
%   Outputs:
%   r: reconsturcted high-res image
%   err: errors at each iteration
%
%   Inputs:
% Measurements data
%   I: intensity measurements by different LEDs
%   du: sampling pixel size in spatial freq domain
%   um: Max spatial freq of I set by NA
% Reconstruction parameters
%   No = [Ny_obj,Nx_obj]: size of the reconstructed image
%
%
% Illumination coding parameters
%   Ns = [Nsy,Nsx]: centers of corresponding lpf regions for
%   the illumination pattern

% Iteration parameters: opts
%   update_mode: different update method to treat sub-images created by
%   different pts on the LED
%   update_mode = 1 (default):
%   weighted average; = 0: direct replacement sequentially
%   tol: maximum change of error allowed in two consecutive iterations
%   maxIter: maximum iterations allowed
%   minIter: minimum iterations
%   monotone (1, default): if monotone, error has to monotonically dropping
%   when iters>minIter
%   display: display results (0: no (default) 1: yes)
%   saveIterResult: save results at each step as images (0: no (default) 1: yes)
%   R0: initial guess of R
%
%% reconstruction algorithm: partial coherence effect in both spatial and
% Fourier domain
% spatial updating method:
% ref [1] C. Rydberg, J. Bengtsson, Opt. Express, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the idea of the inverse algorithm is that each point on LED is a coherent
% mode. The total intensity is the sum of the intensities due to all the
% modes.
% although we do not know the actual intensity for each modes, as show in
% [1], an update rule for amplitude can be found by properly scale the
% estimated amplitude for each modes. Again, the phase part is left
% unchanged.
%
% within each LED, different sub-images' spectrum are replaced sequentially
% last modified 08/19/2013
%
% within each LED, weighted average of the spectrum overlapping patches of
% all the sub-images
% last modified 08/19/2013
%
% last modified 3/1/2014
% 
% implementing the adaptive routine described in
% Z. Bian, S. Dong & G. Zheng, OE, 2013
% Last modified on 03/25/2014


% by Lei Tian, lei_tian@berkeley.edu

%% derived constants
% size of measurement
[Nmy,Nmx,Nimg] = size(I);
Np = [Nmy,Nmx];
% # of LEDs lit up in each pattern, # of coherent modes
[r,~,~] = size(Ns);
cen0 = No/2+1;

%% Define Fourier operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));
% col = @(x) x(:);
row = @(x) x(:).';


%% options for the method
if nargin<4
    % default values
    opts.tol = 1;
    opts.maxIter = 50;
    opts.minIter = 3;
    opts.monotone = 1;
    opts.update_mode = 1;
    opts.display = 0;
    opts.saveIterResult = 0;
    opts.out_dir = [];
    opts.O0 = F(sqrt(I(:,:,1)))/r;
    opts.O0 = padarray(opts.O0,(No-Np)/2);
    opts.P0 = ones(Np);
    opts.alpha = 1;
    opts.beta = 1;
    opts.mode = 'real';
    opts.adaptive = 0;
    opts.adaptivemask = [];
%     opts.Npad = [0,0];
else
    if ~isfield(opts,'tol')
        opts.tol = 1;
    end
    if ~isfield(opts,'maxIter')
        opts.maxIter = 50;
    end
    if ~isfield(opts,'minIter')
        opts.minIter = 3;
    end
    if ~isfield(opts,'monotone')
        opts.monotone = 1;
    end
    if ~isfield(opts,'update_mode')
        opts.update_mode = 1;
    end
    if ~isfield(opts,'display')
        opts.display = 0;
    end
    if ~isfield(opts,'saveIterResult')
        opts.saveIterResult = 0;
    end
    if ~isfield(opts,'out_dir')
        opts.out_dir = ['IterResults'];
        if opts.saveIterResult
            mkdir(opts.out_dir);
        end
    end
    if ~isfield(opts,'O0')
        opts.O0 = F(sqrt(I(:,:,1)))/r;
        opts.O0 = padarray(opts.O0,(No-Np)/2);
    end
    if ~isfield(opts,'P0')
        opts.P0 = ones(Np);
    end
    if ~isfield(opts,'alpha')
        opts.alpha = 1;
    end
    if ~isfield(opts,'beta')
        opts.beta = 1;
    end  
    if ~isfield(opts,'mode')
        opts.mode = 'real';
    end  
    if ~isfield(opts,'Ps')
        opts.Ps = 1;
    end
    if ~isfield(opts,'iters')
        opts.iters = 10;
    end  
    if ~isfield(opts,'adaptive')
        opts.adaptive = 0;
    end   
    % define the region when calculating the mean in the adaptive step
    if ~isfield(opts,'adaptivemask')
        opts.adaptivemask = [];
    end  
%     if ~isfield(opts,'adaptivemask')
%         opts.Npad = [0,0];
%     end
end


%% Operators
alpha = opts.alpha;
beta = opts.beta;
Ps = opts.Ps;
iters = opts.iters;
if opts.adaptive
    P1 = @(psi,I,mode) Proj_Fourier_Adaptive(psi, I, opts.adaptivemask, mode);
else
    P1 = @(psi,I) Proj_Fourier(psi, I);
end
P2 = @(O,P,psi,psi0,cen)...
    GDUpdate_Multiplication2(O,P,psi,psi0,cen,Ps,alpha,beta,iters);
%P2 = @(O,P,psi,cen) MinUpdate_Multiplication(O,P,psi,cen,Ps,iters);
% % operator to put P at proper location at the O plane
% upsamp = @(x,cen) padarray(padarray(x,(No-Np)/2-(cen0-cen),'pre')...
%     ,(No-Np)/2+(cen0-cen),'post');
% operator to crop region of O from proper location at the O plane
% downsamp = @(x,cen) x(cen(1)-Np(1)/2:cen(1)+Np(1)/2-1,...
%     cen(2)-Np(2)/2:cen(2)+Np(2)/2-1);

u = [-1/2:1/No(2):1/2-1/No(2)];
v = [-1/2:1/No(1):1/2-1/No(1)];
[u,v] = meshgrid(u,v);
% define opeators
shift = @(x,s) Ft(F(x).*exp(1i*2*pi*(s(2)*u+s(1)*v)));
crop = @(x) x(cen0-Np(1)/2:cen0+Np(1)/2-1,cen0-Np(2)/2:cen0+Np(2)/2-1);
upsamp = @(x,s) shift(padarray(x,[(No-Np)/2]),s);
downsamp = @(x,s) crop(shift(x,s));
u2 = [-1/2:1/Np(2):1/2-1/Np(2)];
v2 = [-1/2:1/Np(1):1/2-1/Np(1)];
[u2,v2] = meshgrid(u2,v2);
shift2 = @(x,s) Ft(F(x).*exp(1i*2*pi*(s(2)*u2+s(1)*v2)));

T0 = clock;

fprintf('| iter |  rmse    |\n');
for j=1:20, fprintf('-'); end
fprintf('\n');



% %% set up the lpf cutoff freq determined by NA
% u = [-Nmx/2:Nmx/2-1]*du(2);
% v = [-Nmy/2:Nmy/2-1]*du(1);
% [u,v] = meshgrid(u,v);
% % assume a circular pupil function
% w_NA0 = sqrt(u.^2+v.^2)<=um;
% w_NA = double(w_NA0);
%% initialization in FT domain
% using the on-axis (brightfield) image since it contains the DC
% information

P = opts.P0; %opts.P0 = 0;
O = opts.O0; opts.O0 = 0;
err1 = inf;
err2 = 50;
err = [];
iter = 0;
c_vec = zeros(Nimg,opts.maxIter);

if opts.display
%     figure(66); imagesc(log(abs(O))); axis image; colorbar;
    if strcmp(opts.mode,'real')
        o = O;
    elseif strcmp(opts.mode,'fourier')
        o = F(O);
    end
    f1 = figure(88);
    subplot(221); imagesc(abs(o)); axis image; colormap gray; colorbar;
    title('ampl(o)');
    subplot(222); imagesc(angle(o)); axis image; colormap gray; colorbar;
    title('phase(o)');
    subplot(223); imagesc(abs(P)); axis image; colormap gray; colorbar;
    title('ampl(P)');
    subplot(224); imagesc(angle(P).*abs(P)); axis image; colormap jet; colorbar;
    title('phase(P)');
    drawnow;
end

if opts.saveIterResult
    saveas(f1,[opts.out_dir,'\R_',num2str(iter),'.png']);
    %     saveas(f2,[opts.out_dir,'\Ph_',num2str(iter),'.png']);
end


%% main algorithm starts here
% stopping criteria: when relative change in error falls below some value,
% can change this value to speed up the process by using a larger value but
% will trading off the reconstruction accuracy
% error is defined by the difference b/w the measurement and the estimated
% images in each iteration

fprintf('| %2d   | %.2e |\n',iter,err1);

while abs(err1-err2)>opts.tol&&iter<opts.maxIter
    err1 = err2;
    err2 = 0;
    iter = iter+1;
   
    for m = 1:Nimg
        % at the start of each iteration, computes the current support of O
        % in order to add a support constraint to the subpixel shift result
%         So = double(O>mean2(abs(O)));
        % initilize psi for correponing image, RIO determined by cen
        psi0 = zeros(Np(1),Np(2),r);
%         cen = zeros(2,r);
        s = zeros(2,r);
        for p = 1:r
            s(:,p) = row(Ns(p,m,:));
            Pshift = shift2(P,s(:,p));
            Pshift = Pshift.*double(abs(Pshift)>.2);
            psi0(:,:,p) = downsamp(O,s(:,p)).*P.*Pshift;

%             psi0(:,:,p) = downsamp(O,s(:,p)).*P;
%             cen(:,p) = cen0+row(Ns(p,m,:));
%             psi0(:,:,p) = downsamp(O,cen(:,p)).*P;
%             Sos = downsamp(So,s(:,p));
%             Sos = double(Sos>mean2(abs(Sos)));
%             psi0(:,:,p) = downsamp(O,s(:,p)).*P.*Sos;
%             psi0(:,:,p) = downsamp(O,s(:,p)).*P;
%             s(:,p) = row(Ns(p,m,:));
%             % shifting the aperture rather than shifting O
%             Pshift = upsamp(P,-s(:,p));
%             Pshift = Pshift.*double(abs(Pshift)>.1);
%             psi0(:,:,p) = crop(O.*Pshift);
        end
        % measured intensity
        I_mea = I(:,:,m);
        
        if opts.adaptive
            % projection 1
            if iter<2
                [psi, I_est, c] = P1(psi0,I_mea,'nonadaptive');
            else
                [psi, I_est, c] = P1(psi0,I_mea,'adaptive');
                % overwrite the intensity measurement
                I_mea = c*I_mea;
                I(:,:,m) = I_mea;
            end
            c_vec(m,iter) = c;
        else
            [psi, I_est] = P1(psi0,I_mea);
        end
        % projection 2
        %[O,P] = P2(O,P,psi,psi0,cen);
        [O,P] = P2(O,P,psi,psi0,s);


        if strcmp(opts.display,'full')
            %figure(66); imagesc(log(abs(O))); axis image; colorbar;
            if strcmp(opts.mode,'real')
                o = O;
            elseif strcmp(opts.mode,'fourier')
                o = F(O);
            end
            f1 = figure(88);
            subplot(221); imagesc(abs(o)); axis image; colormap gray; colorbar;
            title('ampl(o)');
            subplot(222); imagesc(angle(o)); axis image; colormap gray; colorbar;
            title('phase(o)');
            subplot(223); imagesc(abs(P)); axis image; colormap gray; colorbar;
            title('ampl(P)');
            subplot(224); imagesc(angle(P).*abs(P)); axis image; colormap jet; colorbar;
            title('phase(P)');
            figure(99); imagesc(log(abs(O))); axis image; 
            drawnow;
        end
        %end
        % compute the total difference to determine stopping criterion
        err2 = err2+sqrt(sum((I_mea(:)-I_est(:)).^2))/mean2(I_mea);
    end
    % record the error and can check the convergence later.
    err = [err,err2];
    
    if strcmp(opts.display,'iter')
        %figure(66); imagesc(log(abs(O))); axis image; colorbar;
        if strcmp(opts.mode,'real')
            o = O;
        elseif strcmp(opts.mode,'fourier')
            o = F(O);
        end
        f1 = figure(88);
        subplot(221); imagesc(abs(o)); axis image; colormap gray; colorbar;
        title('ampl(o)');
        subplot(222); imagesc(angle(o)); axis image; colormap gray; colorbar;
        title('phase(o)');
        subplot(223); imagesc(abs(P)); axis image; colormap gray; colorbar;
        title('ampl(P)');
        subplot(224); imagesc(angle(P).*abs(P)); axis image; colormap jet; colorbar;
        title('phase(P)');
        figure(99); imagesc(log(abs(O))); axis image; 
        drawnow;
    end
    
    fprintf('| %2d   | %.2e |\n',iter,err2);
    
    if opts.saveIterResult
        saveas(f1,[opts.out_dir,'\R_',num2str(iter),'.png']);
        %     saveas(f2,[opts.out_dir,'\Ph_',num2str(iter),'.png']);
    end
    
    if opts.monotone&&iter>opts.minIter
        if err2>err1
            break;
        end
    end
    
    
end

if strcmp(opts.mode,'fourier')
    O = F(O);
end

c_vec = c_vec(:,1:iter);

fprintf('elapsed time: %.0f seconds\n',etime(clock,T0));

end

