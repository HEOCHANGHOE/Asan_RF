function [out] = GLCM_Features3(glcmin,pairs)
%
% This is an update of GLCM_Features1 (non vectorized) without ismember()
%
% GLCM_Features3 helps to calculate the features from the different GLCMs
% that are input to the function. The GLCMs are stored in a i x j x n
% matrix, where n is the number of GLCMs calculated usually due to the
% different orientation and displacements used in the algorithm. Usually
% the values i and j are equal to 'NumLevels' parameter of the GLCM
% computing function graycomatrix(). Note that matlab quantization values
% belong to the set {1,..., NumLevels} and not from {0,...,(NumLevels-1)}
% as provided in some references
% http://www.mathworks.com/access/helpdesk/help/toolbox/images/graycomatrix
% .html
%
% Although there is a function graycoprops() in Matlab Image Processing
% Toolbox that computes four parameters Contrast, Correlation, Energy,
% and Homogeneity. The paper by Haralick suggests a few more parameters
% that are also computed here. The code is not fully vectorized and hence
% is not an efficient implementation but it is easy to add new features
% based on the GLCM using this code. Takes care of 3 dimensional glcms
% (multiple glcms in a single 3D array)
%
% If you find that the values obtained are different from what you expect
% or if you think there is a different formula that needs to be used
% from the ones used in this code please let me know.
% A few questions which I have are listed in the link
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/239608
%
% I plan to submit a vectorized version of the code later and provide
% updates based on replies to the above link and this initial code.
%
% Features computed
% Autocorrelation: [2]                      *(out.autoc)*
% Contrast: matlab/[1,2]                    *(out.contr)*
% Correlation: matlab                       *(out.corrm)*
% Harralick Correlation: [1,2]              *(out.corrp)*
% Cluster Prominence: [2]                   *(out.cprom)*
% Cluster Shade: [2]                        *(out.cshad)*
% Dissimilarity: [2]                        *(out.dissi)*
% Energy: matlab / [1,2]                    *(out.energ)*
% Entropy: [2]                              *(out.entro)*
% Homogeneity: matlab                       *(out.homom)*
% Homogeneity: [2]   =IDM                   *(out.homop)* = idmmen
% Maximum probability: [2]                  *(out.maxpr)*
% Sum of sqaures: Variance [1]              *(out.sosvh)*
% Sum average [1]                           *(out.savgh)*
% Sum variance [1]                          *(out.svarh)*
% Sum entropy [1]                           *(out.senth)*
% Difference variance [1]                   *(out.dvarh)*
% Difference entropy [1]                    *(out.denth)*
% Information measure of correlation1 [1]   (out.inf1h)*
% Informaiton measure of correlation2 [1]   (out.inf2h)*
% Inverse difference normalized (INN) [3]   *(out.indncF)*
% Inverse difference moment normalized [3]  (out.idmncF)*


% �߰�
% Cluster Tendency                          *(out.cstend)*
% Difference Average                        *(out.daverg)*
% Inverse difference moment                 (out.idmmen) x
% Inverse Variance                          *(out.invari)*
% Variance                                  (out.varian) x
% Harralick Correlation                     (out.harral) x


% The maximal correlation coefficient was not calculated due to
% computational instability
% http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%
% Formulae from MATLAB site (some look different from
% the paper by Haralick but are equivalent and give same results)
% Example formulae:
% Contrast = sum_i(sum_j(  (i-j)^2 * p(i,j) ) ) (same in matlab/paper)
% Correlation = sum_i( sum_j( (i - u_i)(j - u_j)p(i,j)/(s_i.s_j) ) ) (m)
% Correlation = sum_i( sum_j( ((ij)p(i,j) - u_x.u_y) / (s_x.s_y) ) ) (p[2])
% Energy = sum_i( sum_j( p(i,j)^2 ) )           (same in matlab/paper)
% Homogeneity = sum_i( sum_j( p(i,j) / (1 + |i-j|) ) ) (as in matlab)
% Homogeneity = sum_i( sum_j( p(i,j) / (1 + (i-j)^2) ) ) (as in paper)
%
% Where:
% u_i = u_x = sum_i( sum_j( i.p(i,j) ) ) (in paper [2])
% u_j = u_y = sum_i( sum_j( j.p(i,j) ) ) (in paper [2])
% s_i = s_x = sum_i( sum_j( (i - u_x)^2.p(i,j) ) ) (in paper [2])
% s_j = s_y = sum_i( sum_j( (j - u_y)^2.p(i,j) ) ) (in paper [2])
%
%
% Normalize the glcm:
% Compute the sum of all the values in each glcm in the array and divide
% each element by it sum
%
% Haralick uses 'Symmetric' = true in computing the glcm
% There is no Symmetric flag in the Matlab version I use hence
% I add the diagonally opposite pairs to obtain the Haralick glcm
% Here it is assumed that the diagonally opposite orientations are paired
% one after the other in the matrix
% If the above assumption is true with respect to the input glcm then
% setting the flag 'pairs' to 1 will compute the final glcms that would result
% by setting 'Symmetric' to true. If your glcm is computed using the
% Matlab version with 'Symmetric' flag you can set the flag 'pairs' to 0
%
% References:
% 1. R. M. Haralick, K. Shanmugam, and I. Dinstein, Textural Features of
% Image Classification, IEEE Transactions on Systems, Man and Cybernetics,
% vol. SMC-3, no. 6, Nov. 1973
% 2. L. Soh and C. Tsatsoulis, Texture Analysis of SAR Sea Ice Imagery
% Using Gray Level Co-Occurrence Matrices, IEEE Transactions on Geoscience
% and Remote Sensing, vol. 37, no. 2, March 1999.
% 3. D A. Clausi, An analysis of co-occurrence texture statistics as a
% function of grey level quantization, Can. J. Remote Sensing, vol. 28, no.
% 1, pp. 45-62, 2002
% 4. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%
%
% Example:
%
% Usage is similar to graycoprops() but needs extra parameter 'pairs' apart
% from the GLCM as input
% I = imread('circuit.tif');
% GLCM2 = graycomatrix(I,'Offset',[2 0;0 2]);
% stats = GLCM_features3(GLCM2,0)
% The output is a structure containing all the parameters for the different
% GLCMs
%
% [Avinash Uppuluri: avinash_uv@yahoo.com: Last modified: 04/05/2010]

% If 'pairs' not entered: set pairs to 0
if ((nargin > 2) || (nargin == 0))
    error('Too many or too few input arguments. Enter GLCM and pairs.');
elseif ( (nargin == 2) )
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
        error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
        error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end
elseif (nargin == 1) % only GLCM is entered
    pairs = 0; % default is numbers and input 1 for percentage
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
        error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
        error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end
end


format long e
if (pairs == 1)
    newn = 1;
    for nglcm = 1:2:size(glcmin,3)
        glcm(:,:,newn)  = glcmin(:,:,nglcm) + glcmin(:,:,nglcm+1);
        newn = newn + 1;
    end
elseif (pairs == 0)
    glcm = glcmin;
end

size_glcm_1 = size(glcm,1);
size_glcm_2 = size(glcm,2);
size_glcm_3 = size(glcm,3);

% checked
out.asm=zeros(1,size_glcm_3);     % Angular second momnet
out.autoc = zeros(1,size_glcm_3); % Autocorrelation: [2]    *
out.cprom = zeros(1,size_glcm_3); % Cluster Prominence: [2] *
out.cshad = zeros(1,size_glcm_3); % Cluster Shade: [2] *
out.cstend = zeros(1,size_glcm_3); % Cluster Tendency : [2] *
out.contr = zeros(1,size_glcm_3); % Contrast: matlab/[1,2]  *
out.corrm = zeros(1,size_glcm_3); % Correlation: matlab *
%out.corrp = zeros(1,size_glcm_3); % Correlation: [1,2]
out.daverg =  zeros(1,size_glcm_3); % Difference Average *
out.denth = zeros(1,size_glcm_3); % Difference entropy [1] *
out.dvarh = zeros(1,size_glcm_3); % Difference variance [4] *
out.dissi = zeros(1,size_glcm_3); % Dissimilarity: [2] *
out.energ = zeros(1,size_glcm_3); % Energy: matlab / [1,2] *
out.entro = zeros(1,size_glcm_3); % Entropy: [2] *
out.harral = zeros(1,size_glcm_3); % Harralick Correlation
%out.homop = zeros(1,size_glcm_3); % Homogeneity: [2]
out.homom = zeros(1,size_glcm_3); % Homogeneity: matlab

out.inf1h = zeros(1,size_glcm_3); % Information measure of correlation1 [1]
out.inf2h = zeros(1,size_glcm_3); % Informaiton measure of correlation2 [1]
out.idmmen = zeros(1,size_glcm_3); % Inverse Difference Moment (IDM) or Homogeneity 2

out.idmncF = zeros(1,size_glcm_3); % Inverse difference moment normalized [3]
out.indncF = zeros(1,size_glcm_3); % Inverse difference normalized (IDN) [3]
out.invari = zeros(1,size_glcm_3); % Inverse Variance
out.maxpr = zeros(1,size_glcm_3); % Maximum probability: [2] *

out.mean = zeros(1,size_glcm_3); % Mean

out.savgh = zeros(1,size_glcm_3); % Sum average [1] *
out.senth = zeros(1,size_glcm_3); % Sum entropy [1] *
out.svarh = zeros(1,size_glcm_3); % Sum variance [1] *
out.sosvh = zeros(1,size_glcm_3); % Sum of sqaures: Variance [1]
out.varian = zeros(1,size_glcm_3); % Variance

% out.dvarh2 = zeros(1,size_glcm_3); % Difference variance [1]
% out.corm = zeros(1,size_glcm_3);


%out.varian2 = zeros(1,size_glcm_3);

% correlation with alternate definition of u and s
%out.corrm2 = zeros(1,size_glcm_3); % Correlation: matlab
%out.corrp2 = zeros(1,size_glcm_3); % Correlation: [1,2]

glcm_sum  = zeros(size_glcm_3,1);
glcm_mean = zeros(size_glcm_3,1);
glcm_var  = zeros(size_glcm_3,1);

% http://www.fp.ucalgary.ca/mhallbey/glcm_mean.htm confuses the range of
% i and j used in calculating the means and standard deviations.
% As of now I am not sure if the range of i and j should be [1:Ng] or
% [0:Ng-1]. I am working on obtaining the values of mean and std that get
% the values of correlation that are provided by matlab.
u_x = zeros(size_glcm_3,1);
u_y = zeros(size_glcm_3,1);
s_x = zeros(size_glcm_3,1);
s_y = zeros(size_glcm_3,1);

% % alternate values of u and s
% u_x2 = zeros(size_glcm_3,1);
% u_y2 = zeros(size_glcm_3,1);
% s_x2 = zeros(size_glcm_3,1);
% s_y2 = zeros(size_glcm_3,1);

% checked p_x p_y p_xplusy p_xminusy
p_x = zeros(size_glcm_1,size_glcm_3); % Ng x #glcms[1]
p_y = zeros(size_glcm_2,size_glcm_3); % Ng x #glcms[1]
p_xplusy = zeros((size_glcm_1*2 - 1),size_glcm_3); %[1]
p_xminusy = zeros((size_glcm_1),size_glcm_3); %[1]
% checked hxy hxy1 hxy2 hx hy
hxy  = zeros(size_glcm_3,1);
hxy1 = zeros(size_glcm_3,1);
hx   = zeros(size_glcm_3,1);
hy   = zeros(size_glcm_3,1);
hxy2 = zeros(size_glcm_3,1);

%Q    = zeros(size(glcm));

for k = 1:size_glcm_3 % number glcms
    
    glcm_sum(k) = sum(sum(glcm(:,:,k)));
    glcm(:,:,k) = glcm(:,:,k)./glcm_sum(k); % Normalize each glcm
    glcm_mean(k) = mean2(glcm(:,:,k)); % compute mean after norm
    glcm_var(k)  = (std2(glcm(:,:,k)))^2;
    
    for i = 1:size_glcm_1
        
        for j = 1:size_glcm_2
            out.asm(k)=out.asm(k) + glcm(i,j,k)*glcm(i,j,k);
            out.contr(k) = out.contr(k) + (abs(i - j))^2.*glcm(i,j,k);
            out.dissi(k) = out.dissi(k) + (abs(i - j)*glcm(i,j,k));
            out.energ(k) = out.energ(k) + (glcm(i,j,k).^2);
            out.entro(k) = out.entro(k) - (glcm(i,j,k)*log(glcm(i,j,k) + eps));
            out.homom(k) = out.homom(k) + (glcm(i,j,k)/( 1 + abs(i-j) ));
            %out.homop(k) = out.homop(k) + (glcm(i,j,k)/( 1 + (i - j)^2));
            % [1] explains sum of squares variance with a mean value;
            % the exact definition for mean has not been provided in
            % the reference: I use the mean of the entire normalized glcm
            out.sosvh(k) = out.sosvh(k) + glcm(i,j,k)*((i - glcm_mean(k))^2);
            
            %out.invdc(k) = out.homom(k);
            out.indncF = out.indncF + (glcm(i,j,k)/( 1 + (abs(i-j)/size_glcm_1))); % changed 19/24/01
            out.idmncF = out.idmncF + (glcm(i,j,k)/( 1 + ((i - j)/size_glcm_1)^2)); % changed 19/24/01
            %out.indncF = out.indncF + (glcm(i,j,k)/( 1 + (abs(i-j))));
            %out.idmncF = out.idmncF + (glcm(i,j,k)/( 1 + (i - j)^2));
            
            out.idmmen(k) =  out.idmmen(k) + (glcm(i,j,k)/( 1 + (i - j)^2));
            if i~=j
                out.invari(k) =  out.invari(k) + (glcm(i,j,k)/((i-j)^2));
            end
            
            out.varian(k) = out.varian(k) + (i-glcm_mean(k))^2*glcm(i,j,k);
            out.harral(k) = out.harral(k) + (i*j*(glcm(i,j,k)) - mean(p_x(:,k)));
            
            u_x(k)          = u_x(k) + (i)*glcm(i,j,k); % changed 10/26/08
            u_y(k)          = u_y(k) + (j)*glcm(i,j,k); % changed 10/26/08
            % code requires that Nx = Ny
            % the values of the grey levels range from 1 to (Ng)
        end
        
    end
    out.maxpr(k) = max(max(glcm(:,:,k)));
    %out.indncF(k) = out.indncF/size_glcm_1;
    %out.idmncF(k) = out.idmncF / (size_glcm_1^2);
end

for k = 1:size_glcm_3
    for i = 1:size_glcm_1
        for j = 1:size_glcm_2
            p_x(i,k) = p_x(i,k) + glcm(i,j,k);
            p_y(i,k) = p_y(i,k) + glcm(j,i,k); % taking i for j and j for i
            %if (ismember((i + j),[2:2*size_glcm_1]))
            p_xplusy((i+j)-1,k) = p_xplusy((i+j)-1,k) + glcm(i,j,k);
            %end
            %if (ismember(abs(i-j),[0:(size_glcm_1-1)]))
            p_xminusy((abs(i-j))+1,k) = p_xminusy((abs(i-j))+1,k) +...
                glcm(i,j,k);
            %end
            
        end
    end
    
    %     % consider u_x and u_y and s_x and s_y as means and standard deviations
    %     % of p_x and p_y
    %     u_x2(k) = mean(p_x(:,k));
    %     u_y2(k) = mean(p_y(:,k));
    %     s_x2(k) = std(p_x(:,k));
    %     s_y2(k) = std(p_y(:,k));
    
end

% computing sum average, sum variance and sum entropy:
for k = 1:(size_glcm_3)
    
    for i = 1:(2*(size_glcm_1)-1)
        out.savgh(k) = out.savgh(k) + (i+1)*p_xplusy(i,k);
        % the summation for savgh is for i from 2 to 2*Ng hence (i+1)
        out.senth(k) = out.senth(k) - (p_xplusy(i,k)*log(p_xplusy(i,k) + eps));
    end
    
end
% compute sum variance with the help of sum entropy
for k = 1:(size_glcm_3)
    
    for i = 1:(2*(size_glcm_1)-1)
        out.svarh(k) = out.svarh(k) + (((i+1) - out.senth(k))^2)*p_xplusy(i,k);
        % the summation for savgh is for i from 2 to 2*Ng hence (i+1)
    end
    
end
% compute difference variance, difference entropy,
for k = 1:size_glcm_3
    out.dvarh(k) = var(p_xminusy(:,k));
    % but using the formula in
    % http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
    % we have for dvarh
    for i = 0:(size_glcm_1-1)
        out.denth(k) = out.denth(k) - (p_xminusy(i+1,k)*log(p_xminusy(i+1,k) + eps));
        %       out.dvarh(k) = out.dvarh(k) + (i^2)*p_xminusy(i+1,k);
        %       out.dvarh(k)= out.dvarh(k) + p_xminusy(i+1,k)*((i - glcm_mean(k))^2);
        out.daverg(k) = out.daverg(k) + (i)*p_xminusy(i+1,k);
        
    end
end

% compute information measure of correlation(1,2) [1]

for k = 1:size_glcm_3
    hxy(k) = out.entro(k);
    for i = 1:size_glcm_1
        
        for j = 1:size_glcm_2
            hxy1(k) = hxy1(k) - (glcm(i,j,k)*log(p_x(i,k)*p_y(j,k) + eps));
            hxy2(k) = hxy2(k) - (p_x(i,k)*p_y(j,k)*log(p_x(i,k)*p_y(j,k) + eps));
        end
        hx(k) = hx(k) - (p_x(i,k)*log(p_x(i,k) + eps));
        hy(k) = hy(k) - (p_y(i,k)*log(p_y(i,k) + eps));
    end
    
    out.inf1h(k) = ( hxy(k) - hxy1(k) ) / ( max([hx(k),hy(k)]) );
    out.inf2h(k) = ( 1 - exp( -2*( hxy2(k) - hxy(k) ) ) )^0.5;
    
end

corm = zeros(size_glcm_3,1);
corp = zeros(size_glcm_3,1);
cori = zeros(size_glcm_3,1);
corv = zeros(size_glcm_3,1);
% using http://www.fp.ucalgary.ca/mhallbey/glcm_variance.htm for s_x s_y
for k = 1:size_glcm_3
    for i = 1:size_glcm_1
        for j = 1:size_glcm_2
            s_x(k)  = s_x(k)  + (((i) - u_x(k))^2)*glcm(i,j,k);
            s_y(k)  = s_y(k)  + (((j) - u_y(k))^2)*glcm(i,j,k);
            
            cori(k)= cori(k) + i * glcm(i,j,k);
            corp(k) = corp(k) + ((i)*(j)*glcm(i,j,k));
            corm(k) = corm(k) + (((i) - u_x(k))*((j) - u_y(k))*glcm(i,j,k));
            corv(k) = corv(k) + (i-cori(k))^2*glcm(i,j,k);
            
            out.cprom(k) = out.cprom(k) + (((i + j - u_x(k) - u_y(k))^4)*glcm(i,j,k));
            out.cshad(k) = out.cshad(k) + (((i + j - u_x(k) - u_y(k))^3)*glcm(i,j,k));
            out.cstend(k) = out.cstend(k) + (((i + j - u_x(k) - u_y(k))^2)*glcm(i,j,k));
        end
    end
    % using http://www.fp.ucalgary.ca/mhallbey/glcm_variance.htm for s_x
    % s_y : This solves the difference in value of correlation and might be
    % the right value of standard deviations required
    % According to this website there is a typo in [2] which provides
    % values of variance instead of the standard deviation hence a square
    % root is required as done below:
    s_x(k) = s_x(k) ^ 0.5;
    s_y(k) = s_y(k) ^ 0.5;
    out.mean(k) = cori(k);
    %out.varian2(k) = corv(k);
    
    out.autoc(k) = corp(k);
    %out.corrp(k) = (corp(k) - u_x(k)*u_y(k))/(s_x(k)*s_y(k));
    out.corrm(k) = corm(k) / (s_x(k)*s_y(k));
    %     % alternate values of u and s
    %     out.corrp2(k) = (corp(k) - u_x2(k)*u_y2(k))/(s_x2(k)*s_y2(k));
    %     out.corrm2(k) = corm(k) / (s_x2(k)*s_y2(k));
end
