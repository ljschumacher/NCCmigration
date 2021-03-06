% using d03ra to solve a pde in a rectangular domain
% checking functions etc.
% for use with chemotaxis_solve.m
% Based on Louise Dyson D.Phil project
% modified by L.J. Schumacher

function [ierr] = chemotaxis_monitr(a, t, b, c, tlast, d, ngpts, xpts, ypts, lsol, sol, ierr)
global param plotsol xsave ysave  % we need to use more parameters that used by the d03ra syntax
% and using global variables is much faster than saving & loading from disk -- LJS

if isunix==1
    ngpts = int32(ngpts); % the NAG documentation calls for this parameter to be int32 -- LJS
end

if tlast
    level = 1;
    npts=ngpts(level);
    if isunix==1
        ipsol=int32(lsol(level)); % this seems to have to be int32 -- LJS
    else
        ipsol=lsol(level);
    end
    
    growingDomain = param.growingDomain;
    tstep = param.tstep;
    
    if growingDomain==1
        Linf = param.Linf;
        a = param.a;
        initialDomainLength = param.initialDomainLength;
        t_s = param.t_s;
        
        [~, L, ~] = domain_growth([],t-tstep,tstep,Linf,a,initialDomainLength,t_s);

        k = sum(ngpts(1:level-1));
        xpts = xpts(k+1:k+npts);
        ypts = ypts(k+1:k+npts);
        xsave = xpts(1:find(xpts(2:end)-xpts(1:end-1)<0,1,'first'));
        xsave(xsave>=0) = xsave(xsave>=0).*L/initialDomainLength;
        ysave = ypts(1:length(xsave):end);
    else
        k = sum(ngpts(1:level-1));
        xpts = xpts(k+1:k+npts);
        ypts = ypts(k+1:k+npts);
        xsave = xpts(1:find(xpts(2:end)-xpts(1:end-1)<0,1,'first'));
        ysave = ypts(1:length(xsave):end);
    end
    
    plotsol = zeros(1,npts);
    for idks=1:npts
        plotsol(idks) = sol(ipsol+idks);
    end
    plotsol = reshape(plotsol,[length(xsave),length(ysave)]);
% uncomment these next to lines to monitor the ca conc during simulation --
% LJS
%     surf(xsave,ysave,plotsol)
%     pause

end
end