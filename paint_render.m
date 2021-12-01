function painting = paint_render(file, threshold, brushstroke, blurfactor, minstrokelen, maxstrokelen, curve, spacing)
if nargin == 0
    error('No file was found')
end
filename = imread(file);
[w,h,l] = size(filename);
if l ~= 3
    error('Input image must be RGB')
end
canvas = ones(size(filename))*128;
painting = zeros(size(filename));
for k=1:numel(brushstroke)
    %this determines the grid
    blank_img = zeros(size(filename));
    R = brushstroke(k);
    grid = spacing * R;     
    % blur to make it more painting like
    gaussIm = imgaussfilt(filename,blurfactor*R);
    refimg = double(gaussIm);
    
    % get luminance
    lum = rgb2ycbcr(gaussIm);
    lum = lum(:,:,1);
    % get gradient properties
    [Gx, Gy] = imgradientxy(lum, 'sobel');
    [Gmag,~] = imgradient(Gx,Gy);
    clear Gdir;
        
    %  using a strel to make the brush shape
    SE = strel('disk',R,8);
    SE = SE.Neighborhood;
    [maskrow, maskcol] = size(SE);
    
    % get difference between canvas and gaussain filtered image
    diff = (canvas - double(gaussIm)).^2;
    diff = (diff(:,:,1) + diff(:,:,2) + diff(:,:,3)).^(1/2);
    rows = grid:grid:w-grid;
    rows = rows(randperm(numel(rows)));
    columns = grid:grid:h-grid;
    columns = columns(randperm(numel(columns)));

    for i = 1:numel(rows)
        r = rows(i);
        for j = 1:numel(columns) 
            c = columns(j); K = zeros(2,1);
            % mask of difference between original and ref
            maskofdiff = diff(r-(grid/2)+1:r+(grid/2),c-(grid/2)+ 1:c+(grid/2),:); 
            % total error
            areaError = sum(sum(maskofdiff)) / grid^2;
            if areaError > threshold
                lastDx = 0; lastDy = 0;
                % find largest error point
                [~, maxind] = max(maskofdiff(:));
                [y, x] = ind2sub(size(maskofdiff),maxind);
                % position of pix in src
                y = r + y;x = c + x; 
                % get color of point from ref image
                strokeColor = refimg(y, x, :);
                K(1,1) = x; K(2,1) = y;
              
                % set of points in stroke
                for s = 1:maxstrokelen
                    if x > h || y > w || x < 1 || y < 1
                        break
                    end
                    if Gmag(y,x) == 0
                        break
                    end
                    % first point direction
                    % derivative direction calculation from the gradient
                    dx = -Gy(y,x); dy = Gx(y,x);
                    % reverse direction if necessary
                    if (lastDx * dx + lastDy * dy < 0)
                        dx = -1 *dx; dy = -1 *dy;
                    end
                    % filter the stroke direction
                    dy = curve*dy + (1-curve)*(lastDy); dx = curve*dx + (1-curve)*(lastDx); 
                    dy = dy /(dx^2 + dy^2)^(1/2); dx = dx /(dx^2 + dy^2)^(1/2); 
                    y = floor(y + R*dy); x = floor(x + R*dx); 
                    lastDx = dx; lastDy = dy;
                    K(1,s+1) = x; K(2,s+1) = y;
                end
                % paint the stroke
                for s = 1:size(K,2)
                    clear mask
                    mask(:,:,1) = strokeColor(1)*SE; mask(:,:,2) = strokeColor(2)*SE; mask(:,:,3) = strokeColor(3)*SE;
                    y = K(2,s); x = K(1,s);
                    minrowstroke = y - floor(maskrow/2); maxrowstroke = y + floor(maskrow/2);
                    mincolstroke = x - floor(maskcol/2); maxcolstroke = x + floor(maskcol/2);
                    if maxrowstroke<= w && minrowstroke > 0 && maxcolstroke<=h  && mincolstroke > 0
                        overlap = ~(mask & blank_img(minrowstroke:maxrowstroke,mincolstroke:maxcolstroke,1:3));
                        mask = mask.*overlap;
                        mask = mask + blank_img(minrowstroke:maxrowstroke,mincolstroke:maxcolstroke,1:3);
                        blank_img(minrowstroke:maxrowstroke,mincolstroke:maxcolstroke,1:3) = mask;
                        %imshow(blank_img);
                    end
                end
            end
        end
    end
    mask = ~(blank_img ~=0);
    painting = painting.*mask;
    painting = painting + blank_img;
    canvas = painting;
%       figure,imshow(painting);
    canvas = double(canvas);
end
overlap = ~(painting & canvas);
canvas = canvas.*overlap;
painting = painting + canvas;
painting = uint8(painting);
end