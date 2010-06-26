function [Xc] = mixGaussImpute(model, X, varargin)
% Fill in NaN entries of X using posterior mode on each row
% Xc(i,j) = E[X(i,j) | D]
%PMTKauthor Hannes Bretschneider

if ~isfield(model, 'mu') || isempty(model.mu)
    if ~isfield(model, 'K') || isempty(model.K)
        model.K = 5;
    end
    model = mixGaussMissingFitEm(X, model.K, varargin{:});
end

mixweight = model.mixweight;
K = length(model.mixweight);
n = size(X, 1);
Xc = X;
for i=1:n
    hidNodes = find(isnan(X(i,:)));
    m = length(hidNodes);
    if isempty(hidNodes), continue, end;
    visNodes = find(~isnan(X(i,:)));
    visValues = X(i,visNodes);
    modelHgivenV.mu = NaN(m,K);
    modelHgivenV.Sigma = NaN(m,K);
    ri = zeros(1, K);
    for k=1:K
        modelK.mu = model.mu(:,k); modelK.Sigma = model.Sigma(:,:,k);
        modelTmp = gaussCondition(modelK, visNodes, visValues);
        modelHgivenV.mu(:,k) = modelTmp.mu';
        modelHgivenV.Sigma(:,k) = diag(modelTmp.Sigma);
        ri(k) = mixweight(k)*gauss(modelK.mu(visNodes),...
            modelK.Sigma(visNodes,visNodes),Xc(i,visNodes));
    end
    ri = normalize(ri);
    Xc(i, hidNodes) =  rowvec(ri * modelHgivenV.mu');
end
end
