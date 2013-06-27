% Louise Dyson D.Phil project chemotaxis_solve, 14/10/09
% using d03ra to solve a pde in a rectangular domain
% requires pdedef.m, bndary.m, deiv.m, monitr.m

function out = chemotaxis_solve(ts,tout,ind,iwk,rwk,cells,initialDomainLength,domainHeight,x_length,y_length,insert)
global plotsol xsave ysave % using global variables is much faster than saving & loading from disk -- LJS
dt = [0; 0; 0]; % initial, min and max time step used ([0;0;0] for defaults)
    
% size of rectangular domain (for numerical solution the problem is scaled
% to a stationary domain of unit length -- LJS)
xmin = 0;
xmax = 1;
ymin = 0;
ymax = domainHeight;

if insert==1
    %         nx = int64(x_length);
    ny = int64(y_length);
    load avi_mat/xlat_new
    nx = int64(length(xlat_new));
    xmin = min(xlat_new);
else
    nx = int64(50); % number of x grid points including boundary
    ny = int64(50);
end
%n = nx*ny; % n by n square grid

% tolerances
tols = 0.5; % grid tolerance
tolt = 0.1;    % time tolerance

opti = zeros(4,1,'int64'); % default integrator options
opti(1) = int64(3); % max num grid levels
opti(2) = int64(20); % max Jacobian evaluations
opti(3) = int64(10);    % max newton iterations
opti(4) = int64(100);   % max linear equation iterations
optr = [1.0;1.0;1.0];   % specifies parameters in the space and time monitors
itrace = int64(0);     % level of trace information

% rwk = zeros(188000,1);
% iwk = zeros(58023,1,'int64');
% save avi_mat/cells cells

[ts, tout, rwk, iwk, ind, ifail] = d03ra(ts, tout, dt, xmin, xmax, ymin, ymax, nx, ny, tols,...
    tolt, 'chemotaxis_pdedef', 'chemotaxis_bndary', 'chemotaxis_pdeiv', 'chemotaxis_monitr', opti, optr,rwk, iwk, itrace,...
    ind);
% load avi_mat/plotsol
% load avi_mat/xsave
% load avi_mat/ysave
out.chemotaxis = plotsol;
out.xsave = xsave*initialDomainLength;
out.ysave = ysave;
out.iwk = iwk;
out.rwk = rwk;