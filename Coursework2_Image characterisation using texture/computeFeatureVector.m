function v = computeFeatureVector(A)
%
% Describe an image A using texture features.
%   A is the image
%   v is a 1xN vector, being N the number of features used to describe the
% image
%

if size(A,3) > 1,
	A = rgb2gray(A);
end


for i=1:14
    offsets = [0 i; -i i; -i 0; -i -i];
    for j=1:4
        glcms = graycomatrix(uint8(A), 'Offset', offsets(j,:), 'NumLevels', 16, 'Symmetric', true);
        v{i,j} = struct2array(graycoprops(glcms, {'contrast','energy','homogeneity','correlation'}));
    end
end

v = cell2mat(v);

%v = v(:)';
