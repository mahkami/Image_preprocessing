%filterwhee%%
clear all
close all
files= dir('*.tif');


% maximg= [];
 minimg= [];

for i=1:numel(files)
     img = imread(files(i).name);
     img = img(:,1570:6860); 
 
     if i == 1
         frames= uint16(zeros(size(img,1),size(img,2),numel(files)));
         frames(:,:,i)= img;
         minimg= img;
     else

         minimg= min(minimg,img);
         frames(:,:,i)= img;
     end
 end

save('frames.mat',  'frames',  '-v7.3')
save('minimg.mat','minimg')

