close all
clc
clear all


%% set figure properties
set(0,'DefaultAxesFontSize',40);
set(0,'DefaultLegendFontSize',40);
set(0,'DefaultTextFontSize', 40)
set(0,'DefaultLineMarkerSize', 20)
set(0,'DefaultLineLineWidth', 5)
% set(0,'DefaultMarkerMarkerSize', 5)
set(0,'defaultUicontrolFontName', 'Arial')
set(0,'defaultUitableFontName', 'Arial')
set(0,'defaultAxesFontName', 'Arial')
set(0,'defaultTextFontName', 'Arial')
set(0,'defaultUipanelFontName', 'Arial')

%%


% max_img = imread('IMG0480.tif');
% % max = imread('maximage.tif');
% % max = double (max(:,:,1));
% max_img = maximg(:,:,1);
load('maxImage.mat')


[x y] = size(maximg);



video = VideoWriter('filter.avi');
video.FrameRate = 2;
open(video);


fig = figure(11);
% subplot(1,2,1)
warning('off','Images:initSize:adjustingMag');
imshow(maximg,[])

title('Initial image')
FF = getframe(fig);
writeVideo(video,FF);
    


filt = ones(x,y);
filt = uint8(filt);

% for i = 1:x
%     for j = 1:y
%
%         norm_max(i,j) = maximg(i,j)/(mean(maximg(i,:))+mean(maximg(:,j)))/2;
%     end
%
% end

%%
% figure();
% imshow(maximg(:,:),[])


for mm = 1:1 % multyplying image with filter for 5 times
    
binary_int = zeros(x,y);

win_range = (3:70);  % variable size of window size for image binarizing

thresh_manipulate = 0; % removing 10 % of threshhold to increase the boundarz sharpness of image

for tt = 1: length(win_range)
    
    win = win_range(tt); % Window size to binarize image
    
    txt_win = num2str(win);
    
    for i = 1:win:x
        
        if (i+win)>= x
            i = x-win;
        end
        
        for j= 1:win:y-1
            
            if (j+win)>= y
                j = y-win;
            end
            
            thresh = graythresh(maximg(i:i+win,j:j+win));
            %         binary_int(i:i+win,j:j+win) = im2bw(maximg(i:i+win,j:j+win),thresh);
            binary_int(i:i+win,j:j+win) = ...
                imbinarize(maximg(i:i+win,j:j+win),(thresh+thresh_manipulate*thresh));
            
        end
    end
    
    
    % adding value 1 to the fractures
    binary_int(328:435,:)   = 1;
    binary_int(1510:1605,:) = 1;
    
    
    % seting boundaries for size of closed boundaries
    high_bound = 900;
    low_bound  = 18;
    
    CC = bwconncomp(binary_int,4); % finding boundaries
    numPixels = cellfun(@numel,CC.PixelIdxList);  % finding size of closed systems
    
    % Finding closed boundaries with a given range
    [~,idx] = find(numPixels>=low_bound & numPixels<=high_bound);
    [~,idx2] = find(numPixels<=low_bound & numPixels>=high_bound);
    
    
    % making a filter
    
    % filt = ones(x,y);
    % filt = uint8(filt);
    
    for i = 1:length(idx)
        
        filt(CC.PixelIdxList{idx(i)}) = 0;
        
    end
    
    
    img_filtered = maximg.*filt;
%     maximg = maximg.*filt;
    
    % subplot(1,2,2)
    figure(12)
    
    imshow(filt,[])
    warning('off','Images:initSize:adjustingMag');
    drawnow
    title('filter')
    
    fig = figure(11);
    % subplot(1,2,1)
    imshow(img_filtered,[])
    warning('off','Images:initSize:adjustingMag');
    title(['Windows Size' txt_win])
    F(i) = getframe(fig);
    writeVideo(video,F(i));
    
    tt
end

close(video)

%  maximg = maximg.*filt;
 
 num_mm = num2str(mm);
 
 figure()
 imshow(img_filtered,[])
 title(['image after sequence' num_mm])
end

%% Method 2 similar to CO2 contact angle

% IMG = imread('IMG0480.tif');
% max = imread('maximage.tif');
% max = double (max(:,:,1));

IMG = maximg;
IMG = IMG(:,:,1);
[x y] = size(IMG);

% filt = ones(x,y);
% filt = uint8(filt);


bwI = adaptivethreshold(IMG(:,:,1),7,0.00001,0);
imshow(bwI)

    % adding value 1 to the fractures
    bwI(328:435,:)   = 1;
    bwI(1510:1605,:) = 1;
    
    
    % seting boundaries for size of closed boundaries
    high_bound = 900;
    low_bound  = 10;
    
    CC = bwconncomp(bwI,4); % finding boundaries
    numPixels = cellfun(@numel,CC.PixelIdxList);  % finding size of closed systems
    
    % Finding closed boundaries with a given range
    [~,idx] = find(numPixels>=low_bound & numPixels<=high_bound);

    % two intermediate variables for comparison of methods
    filt2 = ones(x,y);
    filt3 = filt;
    
    for i = 1:length(idx)
        
        filt(CC.PixelIdxList{idx(i)}) = 0;
        filt2(CC.PixelIdxList{idx(i)}) = 0;
        
    end
    
    
    figure(17)
    subplot(1,3,1)
    imshow(filt2,[])
    title('method similar to CO2')
    subplot(1,3,2)
    imshow(filt3,[])
    title('local binarizing method')
    subplot(1,3,3)
    imshow(filt,[])
    title('sum of two methods')
    
    filt(filt~=0) = 1; 
    img_filtered = IMG.*uint8(filt);
%     maximg = maximg.*filt;
    
    % subplot(1,2,2)
    figure(12)
    
    imshow(filt,[])
    warning('off','Images:initSize:adjustingMag');
    drawnow
    title('filter')
    
    figure(11);
    % subplot(1,2,1)
    imshow(img_filtered,[])
    warning('off','Images:initSize:adjustingMag');
    title('image')
    
    save('filter','filt')
    
    %% Producing mask for PIVlab
    cc = 0;
    for xx = 1:x
        for yy = 1:y
            if filt(xx,yy) == 0
                cc = cc + 1;
                Mask.xmask(cc,1) = xx;
                Mask.ymask(cc,1) = yy;
            end
        end
    end
    
    
    
%% Checking global binarization!!!


thresh = graythresh(maximg);
%         binary_int(i:i+win,j:j+win) = im2bw(maximg(i:i+win,j:j+win),thresh);
binary_int_glob = imbinarize(maximg);

            
fig = figure( 'Name','Global binarization',...
    'Position', get(0, 'Screensize'));

fig.Color = 'w';

imshow(binary_int_glob,[])

F    = getframe(fig);
imwrite(F.cdata, 'Global binarization.png', 'png')
saveas(fig,'Global binarization.eps', 'epsc')
                
                
