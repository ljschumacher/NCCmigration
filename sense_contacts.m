% takes in a theta direction of movement and position of filopodia (--LJS), a cell (x_cell,y_cell)
% position, the position (x_cells,y_cells,) of the other cells and the radius of a cell and
% outputs an angle, theta, of movement for the cell, based on the existence
% of other cells in the area of the filopodium
% based on Louise Dyson D.Phil project 
% modified by L.J. Schumacher

% theta is the movement direction (--LJS), filopodia is the position of the filopodia

function [foundCellidx,filopodia] = sense_contacts(theta,cellidx,...
    x_cells,y_cells,cellRadius,filolength,filopodia)
%% find the coordinates of our cell
x_cell = x_cells(cellidx);
y_cell = y_cells(cellidx);
if cellidx>size(filopodia,1)
    filopodia = [filopodia; NaN(1,size(filopodia,2),2)]; % extend list of filopodia if necessary -- LJS
end
%% the cell extends filopodia in the theta direction(s) %%
if ~isempty(theta)
    x_fil = x_cell + cos(theta)*filolength;   % x coordinate of the filopodia
    y_fil = y_cell + sin(theta)*filolength;     % y coordinate of the filopodia
    filopodia(cellidx,1:length(theta),:) = [x_fil', y_fil'];
else
    x_fil = filopodia(cellidx,:,1);
    y_fil = filopodia(cellidx,:,2);
    theta = atan2(y_fil - y_cell, x_fil - x_cell);
end


%% find the minimum distance from a line (the filopodium) to each of the points (each other cell) %%
% by finding the closest point using x.y = |x||y|cos(theta) (see LD notebook 8/12/09 onwards)
d = NaN(length(theta),length(x_cells));
for i=1:length(x_cells)
    x = x_cells(i);
    y = y_cells(i);
    for j=1:length(theta) % one might be able to optimise this loop by only checking nearest neighbours or working out the distances for all of the cells filopodia at once -- LJS
        A = x-x_fil(j);
        B = y - y_fil(j);
        C = x_cell-x_fil(j);
        D = y_cell-y_fil(j);
        
        dot = A*C+B*D;
        len_sq = C*C+D*D;
        temp = dot/len_sq;
        
        if temp<0
            xx = x_fil(j);
            yy = y_fil(j);
        elseif temp>1
            xx = x_cell;
            yy = y_cell;
        else
            xx = x_fil(j) + temp*C;
            yy = y_fil(j) + temp*D;
        end
        d(j,i) = sqrt((x-xx)^2 + (y-yy)^2);
    end
end
d(:,cellidx) = 10000*ones(length(theta),1); % so that we don't get our cell back again

%% If there is a cell there, [or a cell's filopodium - follow that cell  %%]

if (min(min(d))<cellRadius)
    % if the filopodium finds a cell body then find out which was the
    % nearest such cell that was found
    
    cells_found = find(min(d,[],1)<cellRadius);
    % find the distance from our cell to the cells found
    dist = NaN(1,length(cells_found));
    for i=1:length(cells_found)
        dist(i) = sqrt((x_cell - x_cells(cells_found(i)))^2+(y_cell - y_cells(cells_found(i)))^2);
    end
    foundCellidx = cells_found(dist==min(dist));
    % if two cells are equidistant, randomly pick one
    if numel(foundCellidx)>1
        foundCellidx = randsample(foundCellidx,1);
    end
    % if the filopodia finds another filopodia, then find out which was
    % the nearest such cell that was found
    % this seems to never have been implemented -- LJS
else
    foundCellidx = [];
end
