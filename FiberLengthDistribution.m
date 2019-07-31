clc
clear
close all

% Read all JPEG files from a folder
% Convert microscope image to binary
% Analyze regoinal properties for length


d = uigetdir(pwd, 'Select a folder');
addpath(d);
Folder = dir(fullfile(d, '*.jpg'));
prop_sum = [];

for i = 1:size(Folder,1)
    d = imread(Folder(i).name);
    
    BW = im2bw(d);
    BW = ~BW; %figure; imshow(BW); %figure1
    [~,threshold] = edge(BW,'sobel');
    fudgeFactor = 0.3;
    BW = edge(BW,'sobel',threshold * fudgeFactor); 
    se90 = strel('line',2,90);
    se0 = strel('line',2,0);
    BW = imdilate(BW,[se90 se0]); %figure; imshow(BW); %figure2
    se1 = strel('diamond',3);
    BW = ~BW; BW = imerode(BW,se1);
    BW =  bwareaopen(BW,10,4); %figure; imshow(BW); %figure3  
    se0 = strel('line',4,0);
    BW = imdilate(BW,[se90 se0]);
    BW = imfill(BW,'holes');
    BW = imerode(BW,se1);
    BW = imfill(BW,'holes'); %figure; imshow(BW); %figure 4
    BW =  bwareaopen(BW,5000,8);% figure; imshow(BW); %figure 5
    BW = imclearborder(BW,4); %figure; imshow(BW); %figure 6
    
    CC = bwconncomp(BW);
    properties = regionprops(CC,'MajorAxisLength', 'MinorAxisLength');
    prop_sum = [prop_sum;properties];
end
 
[~,index] = sortrows([prop_sum.MajorAxisLength].'); prop_sum = prop_sum(index(end:-1:1)); clear index;
M = extractfield(prop_sum,'MajorAxisLength');

fibers = size(M,2);
mean_length = mean(M,'all');
median_length = median(M,'all');

%Figure shows progression of image processing 
%  figure;imshowpair(d,BW,'montage');