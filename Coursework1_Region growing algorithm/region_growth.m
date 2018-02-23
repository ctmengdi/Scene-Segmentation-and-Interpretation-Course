function [ output_img ] = region_growth( input_img, thresh )
%REGION_GROWTH Summary of this function goes here
%   Detailed explanation goes here
tic
input_img = double(input_img);
label_value = 1;      % label the region from number 1

%Pre-processing (smoothing)
input_img = imgaussfilt(input_img, 1);

% Works for graylevel images
if size(input_img, 3) ==1
    % Get the size of input image and create a blank image 
    % for saving labels     
    [row, column] = size(input_img);
    label_img = zeros(row, column);
    
    for i = 1:row
        for j = 1:column
            % If the current pixel is not labeled, put it in the queue
            if label_img(i,j) ==0                
                mean = input_img(i,j);
                pxl_num = 2;
                label_img(i,j) = label_value;
                queue = [i,j];
                
                % Check the 8 neighbors of all the pixels in the queue
                % put it in the queue if it's in the same region
                while isempty(queue)~= 1
                    % Create a vector for saving 8 neighbors
                    neighbor8 = [queue(1,1)-1,queue(1,2);
                        queue(1,1)-1,queue(1,2)+1;
                        queue(1,1),queue(1,2)+1;
                        queue(1,1)+1,queue(1,2)+1; ...
                        queue(1,1)+1,queue(1,2);
                        queue(1,1)+1,queue(1,2)-1;
                        queue(1,1),queue(1,2)-1;
                        queue(1,1)-1,queue(1,2)-1];
                    for n = 1:8
                        
                        if neighbor8(n,1) <= 0 || neighbor8(n,1) > row || ...
                                neighbor8(n,2) <= 0 || neighbor8(n,2) > column
                            continue
                        end
                        
                        if abs(input_img(neighbor8(n,1), neighbor8(n,2)) - mean) <= thresh ...
                                && label_img(neighbor8(n,1), neighbor8(n,2)) == 0
                            
                            mean = (mean*pxl_num + input_img(neighbor8(n,1), neighbor8(n,2)))/(pxl_num+1);
                            pxl_num = pxl_num+1;
                            label_img(neighbor8(n,1), neighbor8(n,2)) = label_value;
                            queue = [queue; neighbor8(n,1), neighbor8(n,2)]; %Update the queue
                            
                        end
                    end
                    
                    queue(1,:) = []; %Delete the first element of queue
                end
                
                label_value = label_value+ 1;
            end
        end
    end
end

% Works for color images
if size(input_img, 3) ==3
    [row, column] = size(input_img);
    column = column/3;
    label_img = zeros(row, column);
    for i = 1:row
        for j = 1:column
            
            if label_img(i,j) ==0

                mean = [input_img(i,j,1); input_img(i,j,2);input_img(i,j,3)];
                pxl_num = 2;
                
                if sqrt(double((input_img(i,j,1)- mean(1))^2+(input_img(i,j,2)- mean(2))^2 ...
                        +(input_img(i,j,3)- mean(3))^2)) <= thresh
                    mean = [(mean(1) + input_img(i,j,1)); (mean(2) + input_img(i,j,2));
                        (mean(3) + input_img(i,j,3))]/pxl_num;
                    label_img(i,j) = label_value;
                    queue = [i,j];
                end

                while isempty(queue)~= 1
                    
                    neighbor8 = [queue(1,1)-1,queue(1,2);
                        queue(1,1)-1,queue(1,2)+1;
                        queue(1,1),queue(1,2)+1;
                        queue(1,1)+1,queue(1,2)+1;
                        queue(1,1)+1,queue(1,2);
                        queue(1,1)+1,queue(1,2)-1;
                        queue(1,1),queue(1,2)-1;
                        queue(1,1)-1,queue(1,2)-1];
                    for n = 1:8
                        if neighbor8(n,1) <= 0 || neighbor8(n,1) > row || ...
                                neighbor8(n,2) <= 0 || neighbor8(n,2) > column
                            continue
                        end
                        
                        if sqrt(double((input_img(neighbor8(n,1),neighbor8(n,2),1)- mean(1))^2 + ...
                                (input_img(neighbor8(n,1),neighbor8(n,2),2)- mean(2))^2 + ...
                                (input_img(neighbor8(n,1),neighbor8(n,2),3)- mean(3))^2)) <= thresh ...
                                && label_img(neighbor8(n,1), neighbor8(n,2)) == 0
                            
                            
                            mean = [mean(1)*pxl_num + input_img(neighbor8(n,1), neighbor8(n,2),1);
                                mean(2)*pxl_num + input_img(neighbor8(n,1), neighbor8(n,2),2);
                                mean(3)*pxl_num + input_img(neighbor8(n,1), neighbor8(n,2),3)]/(pxl_num+1);
                            pxl_num = pxl_num + 1;
                            label_img(neighbor8(n,1), neighbor8(n,2)) = label_value;
                            queue = [queue; neighbor8(n,1), neighbor8(n,2)];
                            
                        end
                    end
                    
                    queue(1,:) = [];
                end
                
                label_value = label_value+ 1;
            end
        end
    end
end

%Show the number of regions
num_label = label_value-1;  
S = sprintf('The number of labels/regions is %i', num_label);
disp(S);

%Show the labeled image
figure;

%Comment this 2 lines if there's no pre-processing
subplot(1,2,1); imshow(uint8(input_img), []); title('smoothed image');
subplot(1,2,2);

output_img = imshow(label2rgb(label_img,'colorcube', 'k', 'shuffle'));
title('labeled image');
toc
end

