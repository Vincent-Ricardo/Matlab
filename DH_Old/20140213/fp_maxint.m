%% Reconstruct Minimum Intensity.
% Loads an image that can be read into the Fresnel Propagator.
% Version 3.0

function [Imax, zmap] = fp_maxint(E0, zmin, zmax, numz, lambda, ps, zpad)

if nargin<7
    zpad = size(E0,1);
end

%z positions to reconstruct
z = linspace(zmin, zmax, numz);

wb = waitbar(1/numz,'Reconstructing min intensity...');

%initialize Imin at the first z-step (field magnitude)
Imax = abs(fp_fresnelprop(E0,z(1), lambda, ps, zpad));
zmap = ones(size(E0))*z(1);


%reconstruct the rest of the volume, tracking the intensity 
for i=2:numz
    waitbar(i/numz,wb);
    
   %reconstruct at the next z-plane
    E1 = abs(fp_fresnelprop(E0, z(i), lambda, ps, zpad));
    
    %compare, looking for maximum values
    maxpix = E1>Imax;
    
    %update the memories
    Imax(maxpix) = E1(maxpix);
    zmap(maxpix) = z(i);
    
end

close(wb);