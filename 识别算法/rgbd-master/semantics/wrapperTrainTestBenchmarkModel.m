function evalRes = wrapperTrainModel(trSet, valSet, testSet, typ, classifierType, classMapping)
	paths = getPaths();
	%trSet = 'train1';
	%valSet = 'train2';
	%testSet = 'val';
	%typ = 'generic';
	%classifierType = 'svm-full';
	%classMapping = 'classMapping40';
	%numClass = 40;

	pt = getMetadata(classMapping);
	numClass = length(pt.className);
	if(numClass == 40)
		task = 'entryLevel';
	elseif(numClass == 4)
		task = 'superCategory';
	end

	imSet = {trSet, valSet}; useVal = 1;
	trainingParam.fileSuffix = sprintf('tr-%s_val-%s_useVal-%d', imSet{1}, imSet{2}, useVal);

	featureParam = getAblationParameters(typ);
	trainingParam.featureParam = featureParam;

	gtParam = struct('spFraction', 0.8, 'spArea', 0, 'classMapping', classMapping, 'numClass', numClass);
	trainingParam.gtParam = gtParam;

	[classifierParam] = getClassifierParam(classifierType, struct('useVal', useVal, 'numClass', numClass, 'nVar', featureParam.nVar));
	trainingParam.classifierParam = classifierParam;
	trainingParam.classifierFileName = sprintf('%s_%s_%s', classifierType, task, trainingParam.featureParam.featureCacheName);
	trainingParam.classifierType = classifierType;

	trainingParam.useCache = false;

	bParam = struct('thresh', 0, 'threshPR', [], 'threshIU', 0:0.05:1, 'infoFile', classMapping, 'ignoreBck', true);
	trainingParam.bParam = bParam;

	modelFileName = trainModel(imSet, paths, trainingParam);
	[softOutputDir, hardOutputDir] = testModel(testSet, paths, modelFileName);
	evalRes = benchmarkSemantic(hardOutputDir, classMapping, testSet);

end
