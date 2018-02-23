function example_classifier

% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

% initialize VOC options
VOCinit;

% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
    classifier=train(VOCopts,cls);                  % train classifier
    test(VOCopts,cls,classifier);                   % test classifier
    figure(i);
    [fp,tp,auc]=VOCroc(VOCopts,'comp1',cls,true);   % compute and display ROC
    
    %     if i<VOCopts.nclasses
    %         fprintf('press any key to continue with next class...\n');
    %         pause;
    %     end
end

% train classifier
function classifier = train(VOCopts,cls)

% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');

% extract features for each image
classifier.FD=[];
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    try
        % try to load features
        load(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
        fd=extractfd(VOCopts,I);
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end
    
    classifier.FD=[classifier.FD, fd];
end

% number of clusters
k = 150;

% using k-means to cluster the features and obtain the codebook - dictionary
% classifier.Codebook = vl_kmeans(double(classifier.FD), k, 'Initialization', 'plusplus');
[classifier.Codebook, classifier.covariances, classifier.priors] = vl_gmm(double(classifier.FD), k);



% run classifier on test images
function test(VOCopts,cls,classifier)

% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,VOCopts.testset),'%s %d');

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

% classify each image
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: test: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    try
        % try to load features
        load(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
        fd=extractfd(VOCopts,I);
        save(sprintf(VOCopts.exfdpath,ids{i}),'fd');
    end
    
    % compute confidence of positive classification
    c=classify(VOCopts,classifier,fd);
    
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},c);
end

% close results file
fclose(fid);

%trivial feature extractor: compute SIFT
function fd = extractfd(VOCopts,I)

%I = single(rgb2gray(I));
% im = imcrop(I, [bbox(1,1), bbox(1,2), bbox(1,3)-bbox(1,1), bbox(1,4)-bbox(1,2)]);
%[frames, descriptors] = vl_covdet(im, 'method', 'MultiscaleHessian');

f = kp_log(I, 350);
I_ = vl_imsmooth(im2double(I), sqrt(f(3)^2 - 0.5^2)) ;
[Ix, Iy] = vl_grad(I_) ;
mod = sqrt(Ix.^2 + Iy.^2) ;
ang = atan2(Iy,Ix) ;
grd = shiftdim(cat(3,mod,ang),2) ;
grd = single(grd) ;
fd = vl_siftdescriptor(grd, f) ;

% perm = randperm(size(frames,1));
% p = perm(1:80);
% fd = descriptor(:,p);





% trivial classifier: compute ratio of L2 distance betweeen
% nearest positive (class) feature vector and nearest negative (non-class)
% feature vector
function c = classify(VOCopts,classifier,fd)

% k = 50;
% bag of words
%kdtree = vl_kdtreebuild(classifier.Codebook);

% creating the histogram of visual words for each trining set
TrainMatrix = [];

for i=1:350:size(classifier.FD,2)
%     nn = vl_kdtreequery(kdtree, classifier.Codebook, classifier.FD(:,i));
%     assignments = zeros(k, 1);
%     assignments(sub2ind(size(a(ssignments), double(nn), 1:length(nn))) = 1;
    trainHist = vl_fisher(double(classifier.FD(:,i:i+349)), classifier.Codebook, classifier.covariances, classifier.priors, 'improved');
    %trainHist = trainHist./norm(trainHist);
    TrainMatrix = [TrainMatrix; trainHist'];
end


% creating the histogram of visual words for the test data
% nn_t = vl_kdtreequery(kdtree, classifier.Codebook, double(fd));

%assignments_t = zeros(k, 1);
%assignments_t(sub2ind(size(assignments_t), double(nn_t), 1:length(nn_t))) = 1;

histTest = vl_fisher(double(fd), classifier.Codebook, classifier.covariances, classifier.priors, 'improved');


%Training the SVM classifier
[W, B] = vl_svmtrain(TrainMatrix', classifier.gt, 0.02);

c = W'*histTest + B;

% Run EM starting from the given parameters
% [means,covariances,priors] = vl_gmm(codebook, k);
%
% histTrain = vl_fisher(classifier.FD, means, covariances, priors);
% histTrain = histTrain./norm(histTrain);
%
% histTest = vl_fisher(double(fd), means, covariances, priors);
% histTest = histTest./norm(histTest);

%creating the histogram of visual words for the training
%histTrain = feature_histogram(codebook',classifier.FD');

% creating the histogram of visual words for the test
% [means, covariances, priors] = vl_gmm(classifier.FD, k);
% histTrain = vl_fisher(classifier.FD, means, covariances, priors);




