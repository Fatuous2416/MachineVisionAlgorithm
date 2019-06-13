function [Ellipses, ResizedIm] = detectEllipses(I, showFigures)
% RGB �̹����� �޾Ƽ� �� ���ÿ� �ش��ϴ� Ÿ���� �����ϴ� �Լ�
% Ellipses{i}�� Z, A, B, Alpha�� ���� struct (fitellipse �Լ� ����)

%% Set library paths
addpath('fitellipse');

%% Detect dishes

% process edge
[ResizedIm, Segments] = edgeProcessing(I, false);

% fit ellipses
Ellipses = fitEllipses(Segments);
Ellipses = makeBMinorAxis(Ellipses);

% Ÿ���� Y�� �������� �׿� �ִٰ� �����ϰ� filtering
Ellipses = filterByTilt(Ellipses, 6/180*pi);
Ellipses = filterByMostFrequentX(Ellipses, size(ResizedIm,2) / 10);
Ellipses = filterByMostFrequentA(Ellipses, 0.16);
Ellipses = filterDoubleLine(Ellipses, size(ResizedIm,1) / 40);

% show image to test
if showFigures
    subplot(1,3,1);
    imshow(ResizedIm);
    hold on;
    drawLineSegments(size(ResizedIm), Segments);
    
    subplot(1,3,2);    
    imshow(ResizedIm);
    hold on;
    for i = 1 : length(Ellipses)
        Ellipse = Ellipses{i};
        plotellipse(Ellipse.Z, Ellipse.A, Ellipse.B, Ellipse.Alpha, 'r');
    end
end


%% find missed dish

% initailize
maxIter = 3;
minNumPoints = 4;
errorThre = 0.1;
perimeterRatioThre = 0.1;
numEllipse = length(Ellipses);

[x, y, a, b, alpha] = splitParameters(Ellipses);
AllParams = [x, y, a, b, alpha];


iter = 0;

% check if the bottommost is missed
while iter < maxIter && numEllipse > 1
    iter = iter + 1;
    
    % initialize
    fittingSegment = [];
    firstEllipse = AllParams(1,:);
    secondEllipse = AllParams(2,:);
    newEllipse = 2*firstEllipse - secondEllipse;
    
    % get fitting segment
    [fittingSegment, fittingLength] = getFittingSegment(newEllipse, Segments);
    
    if isempty(fittingSegment) || newEllipse(3) < newEllipse(4)
        break;
    end
    
    % find optimal center and calculate error
    [x, y, error] = findOptimalCenter(newEllipse, fittingSegment);
    
    
    % calculate error of first dish
    numPoints = length(fittingSegment);
    firstSum=0;
    for n = 1:numPoints
        firstSum = firstSum + calcEllipseCost(firstEllipse, fittingSegment(n,:));
    end
    firstError = firstSum/numPoints;
    perimeter = sqrt(2)*pi*norm(newEllipse(3:4));
    
    % insert newEllipse into ellipse set only when it has strong evidences.
    if error < errorThre && error < firstError && fittingLength/perimeter > perimeterRatioThre && length(fittingSegment) >= minNumPoints
        hold on;
        plotellipse([y, x], newEllipse(3), newEllipse(4), newEllipse(5), 'blue');
        numEllipse = numEllipse + 1;
        addEllipse = struct;
        addEllipse.Z = [y; x];
        addEllipse.A = newEllipse(3);
        addEllipse.B = newEllipse(4);
        addEllipse.Alpha = newEllipse(5);
        Ellipses{numEllipse} = addEllipse;
    end
    
    AllParams = [newEllipse; AllParams];
end

% if there exists possible missed dish between any of two,
% check edge fitting and calculate error.
[x, y, a, b, alpha] = splitParameters(Ellipses);
AllParams = [x, y, a, b, alpha];
maxIdx = findMissedStep (AllParams);
iter = 0;
while maxIdx > 0 && iter < maxIter
    
    iter = iter + 1;
    prevEllipse = AllParams(maxIdx,:);
    nextEllipse = AllParams(maxIdx+1,:);
    newEllipse = (prevEllipse+nextEllipse)/2;
    
    % get fitting segment
    [fittingSegment, fittingLength] = getFittingSegment(newEllipse, Segments);
    
    % find optimal center and calculate error
    [x, y, error] = findOptimalCenter(newEllipse, fittingSegment);
    
    % calculate prevError, nextError
    numPoints = length(fittingSegment);
    prevSum=0; nextSum=0;
    for n = 1:numPoints
        prevSum = prevSum + calcEllipseCost(prevEllipse, fittingSegment(n,:));
        nextSum = nextSum + calcEllipseCost(nextEllipse, fittingSegment(n,:));
    end
    prevError = prevSum/numPoints;
    nextError = nextSum/numPoints;
    perimeter = sqrt(2)*pi*norm(newEllipse(3:4));
    
    % insert newEllipse into ellipse set only when it has strong evidences.
    if error < errorThre && error < prevError && error < nextError && fittingLength/perimeter > perimeterRatioThre && length(fittingSegment) >= minNumPoints
        hold on;
        plotellipse([y, x], newEllipse(3), newEllipse(4), newEllipse(5), 'blue');
        numEllipse = numEllipse + 1;
        addEllipse = struct;
        addEllipse.Z = [y; x];
        addEllipse.A = newEllipse(3);
        addEllipse.B = newEllipse(4);
        addEllipse.Alpha = newEllipse(5);
        Ellipses{numEllipse} = addEllipse;
    end
    
    AllParams = [AllParams(1:maxIdx,:); newEllipse; AllParams(maxIdx+1:end,:)];
    maxIdx = findMissedStep (AllParams);
end

Ellipses = filterDoubleLine(Ellipses, size(ResizedIm,1) / 40);

% show image to test
if showFigures
    subplot(1,3,3);
    imshow(ResizedIm);
    hold on;
    for i = 1 : length(Ellipses)
        Ellipse = Ellipses{i};
        plotellipse(Ellipse.Z, Ellipse.A, Ellipse.B, Ellipse.Alpha, 'r');
    end
end

%% Reset added paths
rmpath('fitellipse');

end

%%
function [x, y, errorMin] = findOptimalCenter(newEllipse, fittingSegment);
% newEllipse�� x, y�������� ���������� fittingSegment���� error�� �ּҰ� �Ǵ�
% optimal center�� ã��.

% initailize
xMaxOffset = 3;
yMaxOffset = 10;
xOffset = -xMaxOffset:xMaxOffset;
yOffset = -yMaxOffset:yMaxOffset;
center_x = newEllipse(1) + xOffset;
center_y = newEllipse(2) + yOffset;
errorMin = -1;
numOfPoints = length(fittingSegment);

% calculate minimal error
for i = center_x
    for j = center_y
        errorSum = 0;
        for n = 1:numOfPoints
            errorSum =  errorSum + calcEllipseCost([i, j, newEllipse(3:5)], fittingSegment(n,:));
        end
        errorAvg = errorSum / numOfPoints;
        if errorAvg < errorMin || errorMin == -1
            errorMin = errorAvg;
            x = i;
            y = j;
        end
    end
end

end


%%
function [fittingSegment, fittingLength] = getFittingSegment(newEllipse, Segments)
% newEllipse�� ����� segment�鸸 ��Ƽ� fittingSegment�� ����.

% initailize
fittingSegment=[];
fittingLength = 0;

% Merge all fitting segments
for segIdx = 1 : length(Segments)
    segment = Segments{segIdx};
    errorSum=0;
    flag = 1;
    numPoints = length(segment);
    if numPoints < 4
        continue;
    end
    
    for pointIdx = 1 : numPoints
        point = segment(pointIdx,:);
        error = calcEllipseCost(newEllipse, point);
        errorSum = errorSum + error;
        
        if error > 0.2  % �� ���̶� ũ�� ����� ������� ����
            flag = 0;
            break;
        end
    end
    
    errorAvg = errorSum/numPoints;
    
    
    % error���� ��հ��� ������ merge.
    if flag == 1 && errorAvg < 0.15
        
        plot(segment(:,2), segment(:,1),'LineWidth', 2 );
        fittingSegment = [fittingSegment;segment];
        fittingLength = fittingLength + calcSegmentLength(segment);
    end
    
end

hold on;
plotellipse(newEllipse([2 1]), newEllipse(3), newEllipse(4), newEllipse(5), 'white');

end

%%
function len = calcSegmentLength(segment)
% �־��� segment�� ���̸� ���

numPoints = length(segment);
if numPoints < 2
    error('segment should have more than one points');
end

len = 0;
for i=1:numPoints-1
    len = len + norm(segment(i,:)-segment(i+1,:));

end
end

%%
function maxIdx = findMissedStep (AllParams)
% �� ���� ������ ������ ���� ū ����, ���� ���� ������ ���� ���� �̻� ũ��
% �� index�� ����.

% initialize
ratioThre = 7/4;        % Threshold for min-max distance ratio
y = AllParams(:,2);
numSegments = length(y);
if numSegments < 2
    maxIdx = 0;
    return;
elseif numSegments == 2
    maxIdx = 1;
    return;
end
sumEachParam = sum(AllParams);
thetaAvg = sumEachParam(5)/numSegments;

% check if the minor axis length is a
if abs(thetaAvg)>pi/4 && abs(thetaAvg)<pi*3/4
    bottom = y + AllParams(:,4);
else
    bottom = y + AllParams(:,3);
end

distanceBtwDishes = abs(bottom(1:end-1) - bottom(2:end));
minDstance = min(distanceBtwDishes);
[maxDistance, maxIdx] = max(distanceBtwDishes);

if minDstance * ratioThre >= maxDistance
    maxIdx = 0;
end

end


%%
function BMinorEllipses = makeBMinorAxis(Ellipses)
% Ÿ���� tilt�� �ٲ� Y�� �������� ���̵��� ��.

numEllipse = length(Ellipses);
BMinorEllipses = cell(1,numEllipse);
for i =1:numEllipse
    ellipse = Ellipses{i};
    if abs(ellipse.Alpha) < pi/4 || abs(ellipse.Alpha) > pi*3/4
        temp = ellipse.B;
        ellipse.B = ellipse.A;
        ellipse.A = temp;
        ellipse.Alpha = -abs(abs(ellipse.Alpha) - pi/2);
    end
    BMinorEllipses{i} = ellipse;
end
end

%%
function [Inliers] = filterByTilt(Ellipses, Threshold)
% Ÿ���� ������ ������ ���� ���� (radian)

N = length(Ellipses);
Alphas = zeros(1, N);
for i = 1 : N
    Ellipse = Ellipses{i};
    Alphas(i) = Ellipse.Alpha;
end

Inliers = cell(1, 0);
M = 0;
for i = 1 : N
    if abs(Alphas(i) + pi/2) < Threshold
        M = M + 1;
        Inliers{M} = Ellipses{i};
    end
end

end

%%
function [Inliers] = filterByMostFrequentA(Ellipses, Threshold)
% RANSAN�� ��ݰ� ���ؼ� ����
% Threshold�� Candidate�� A�� ����ؼ� ����

N = length(Ellipses);
As = zeros(1, N);
for i = 1 : N
    Ellipse = Ellipses{i};
    As(i) = Ellipse.A;
end

MaxNum = 0;
InliersIDX = [];
for i = 1 : N
    CandidateA = As(i);
    IDX = abs(As - CandidateA) < CandidateA * Threshold;
    if sum(IDX) > MaxNum
        MaxNum = sum(IDX);
        InliersIDX = IDX;
    end
end

Inliers = cell(1, 0);
M = 0;
for i = 1 : N
    if InliersIDX(i)
        M = M + 1;
        Inliers{M} = Ellipses{i};
    end
end

end

%%
function [Inliers] = filterByMostFrequentX(Ellipses, Threshold)
% RANSAN�� Y�࿡ ������ ������ ���ؼ��� ����

N = length(Ellipses);
Xs = zeros(1, N);
for i = 1 : N
    Ellipse = Ellipses{i};
    Xs(i) = Ellipse.Z(2);
end

MaxNum = 0;
InliersIDX = [];
for i = 1 : N
    CandidateX = Xs(i);
    IDX = abs(Xs - CandidateX) < Threshold;
    if sum(IDX) > MaxNum
        MaxNum = sum(IDX);
        InliersIDX = IDX;
    end
end

Inliers = cell(1, 0);
M = 0;
for i = 1 : N
    if InliersIDX(i)
        M = M + 1;
        Inliers{M} = Ellipses{i};
    end
end

end

%%
function [Inliers] = filterDoubleLine(Ellipses, Threshold)
% Ÿ���� �Ʒ��� ���� Threshold pixel ���Ϸ� ������ ������ �Ʒ� �͸� ����

N = length(Ellipses);

Y = [];
for i = 1 : N
    Ellipse = Ellipses{i};
    Y = [Y; Ellipse.Z(1) + Ellipse.B];
end

[Y, I] = sort(Y, 'descend');

Inliers = cell(1, 0);
if N == 0
    return
end
Inliers{1} = Ellipses{I(1)};
M = 1;

for i = 2 : N
    if Y(i - 1) - Y(i) > Threshold
        M = M + 1;
        Inliers{M} = Ellipses{I(i)};
    end
end

end

%%
function [Ellipses] = fitEllipses(Segments)
% �� segment�� ellipse�� fiiting �õ��Ͽ�, fitting �� ellipse�� ����

Ellipses = cell(1, 0);
NumberOfEllipses = 0;
for i = 1 : length(Segments)
    Segment = Segments{i};
    try
        [Z, A, B, Alpha] = fitellipse(Segment, 'linear');
        NumberOfEllipses = NumberOfEllipses + 1;
        Ellipses{NumberOfEllipses}.Z = Z;
        Ellipses{NumberOfEllipses}.A = A;
        Ellipses{NumberOfEllipses}.B = B;
        Ellipses{NumberOfEllipses}.Alpha = Alpha;
    catch
    end
end

end