%% Applying filter on images


load('maximage.mat')
load('filter.mat')

filt_img = maximg.*filt;

fig = figure('name', 'filtered image',...
    'Position', get(0, 'Screensize'));

imshow(filt_img,[])

F    = getframe(fig);
imwrite(F.cdata, 'filtered image.png', 'png')