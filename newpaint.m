import paint_render.*
file = 'MEFY9126.png';
imshow(file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% threshold: larger int means more tight packed
% brushstroke is the size, must be an array 
% blurfactor is a small number less than 1 
% minstrokelen will be the smallest brush length 
% maxstrokelen will be the largest brush length 
% brush curve will limit curvature of the brush 
% spacing multiples with brush size to determine grid size 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image1 = paint_render(file, 70, [14 12 4], .5, 4, 16, 1, 1);
figure, imshow(image1);
image2 = paint_render(file, 60, [10 6 2], .5, 4, 16, 1.5, 1);
figure, imshow(image2);
image3 = paint_render(file, 60, [10 6 2], 1, 4, 16, 1, 1);
figure, imshow(image3);
image4 = paint_render(file, 50, [8 4 2], .5, 4, 16, 1, 1);
figure, imshow(image4);