function [ label_img] = fuzzycmeans( input_img, num_of_regions)
%FMC_REGION Summary of this function goes here
%   Detailed explanation goes here

tic
img=zeros(size(input_img,3),numel(input_img(:,:,1)));

%prepare the data
for i=1:size(input_img,3)
img(i,:) = double(reshape(input_img(:,:,i),1,[]));
end
img=img';

[center,member]=fcm(img, num_of_regions);


label_img=ones(size(input_img(:,:,1)));

%for each point find the nearest cluster
for i=1:num_of_regions
    maxmember = max(member);
    index=find(member(i,:)== maxmember);
    
    label_img(index)=uint8(i);
    
end

imshow(label2rgb(label_img, 'colorcube', 'k', 'shuffle'));
toc
end

