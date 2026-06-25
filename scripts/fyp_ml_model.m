% =========================================================================
% FYP Phase 3: Architecture & Hyperparameter Tuning
% =========================================================================

disp('Loading 1000-Simulation Dataset...');
load('FYP_RNN_Dataset_1000.mat'); 

num_observations = height(RNN_Dataset);
X_Data = cell(num_observations, 1);

disp('Normalizing 10Hz Data...');
for i = 1:num_observations
    inlet_raw = RNN_Dataset.P_in_Data{i};
    outlet_raw = RNN_Dataset.P_out_Data{i};
    
    inlet_norm = (inlet_raw - mean(inlet_raw)) / std(inlet_raw);
    outlet_norm = (outlet_raw - mean(outlet_raw)) / std(outlet_raw);
    
    X_Data{i} = [inlet_norm'; outlet_norm']; 
end

Y_Classification = categorical(RNN_Dataset.Class_Label);

% Split Data (70% Train [700 sims], 30% Test [300 sims])
cv = cvpartition(num_observations, 'HoldOut', 0.30);
idx_train = training(cv);
idx_test = test(cv);

XTrain = X_Data(idx_train);
YTrain = Y_Classification(idx_train);
XTest = X_Data(idx_test);
YTest = Y_Classification(idx_test);

numFeatures = 2; 
numClasses = 2; 

% =========================================================================
% CHOOSE YOUR MODEL (Uncomment the one you want to test)
% =========================================================================
disp('Building Architecture...');

%% MODEL A: GRU (Default)
% layers = [
%     sequenceInputLayer(numFeatures, 'Name', 'Input')
%     gruLayer(100, 'OutputMode', 'last', 'Name', 'GRU_Default')
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer
% ];
% options = trainingOptions('adam', 'MaxEpochs', 50, 'MiniBatchSize', 16, ...
%     'ValidationData', {XTest, YTest}, 'Plots', 'training-progress', 'Verbose', false);


%% MODEL B: GRU 
% layers = [
%     sequenceInputLayer(numFeatures, 'Name', 'Input')
%     gruLayer(125, 'OutputMode', 'last', 'Name', 'GRU_Optimized')
%     dropoutLayer(0.2)
%     fullyConnectedLayer(numClasses)
%     softmaxLayer
%     classificationLayer
% ];
% options = trainingOptions('adam', 'MaxEpochs', 50, 'MiniBatchSize', 32, ...
%     'InitialLearnRate', 0.001, 'LearnRateSchedule', 'piecewise', ...
%     'LearnRateDropPeriod', 40, 'LearnRateDropFactor', 0.5, ...
%     'ValidationData', {XTest, YTest}, 'Plots', 'training-progress', 'Verbose', false);


%% MODEL C: LSTM (Tuned)
 layers = [
     sequenceInputLayer(numFeatures, 'Name', 'Input')
     lstmLayer(125, 'OutputMode', 'last', 'Name', 'LSTM_Default')
     fullyConnectedLayer(numClasses)
     softmaxLayer
     classificationLayer
 ];
 options = trainingOptions('adam', 'MaxEpochs', 50, 'MiniBatchSize', 16, ...
    'InitialLearnRate', 0.001, 'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 20, 'LearnRateDropFactor', 0.5, ...
    'ValidationData', {XTest, YTest}, 'Plots', 'training-progress', 'Verbose', false);


%% MODEL D: BiLSTM
% layers = [
%    sequenceInputLayer(numFeatures, 'Name', 'Input')

%    bilstmLayer(100, 'OutputMode', 'sequence', 'Name', 'BiLSTM_1')
%    dropoutLayer(0.2, 'Name', 'Dropout_1')

%    bilstmLayer(100, 'OutputMode', 'last', 'Name', 'BiLSTM_2')
%    dropoutLayer(0.2, 'Name', 'Dropout_2')

%    fullyConnectedLayer(numClasses, 'Name', 'FC')
%    softmaxLayer('Name', 'Softmax')
%    classificationLayer('Name', 'Output')
%];
% options = trainingOptions('adam', 'MaxEpochs', 50, 'MiniBatchSize', 32, ...
%    'InitialLearnRate', 0.002, 'LearnRateSchedule', 'piecewise', ...
%    'LearnRateDropPeriod', 20, 'LearnRateDropFactor', 0.4, ...
%    'ValidationData', {XTest, YTest}, 'Plots', 'training-progress', 'Verbose', false);

% =========================================================================
% TRAIN THE NETWORK
% =========================================================================
disp('Starting Training...');
trainedNet = trainNetwork(XTrain, YTrain, layers, options);

% Calculate Final Accuracy
YPred = classify(trainedNet, XTest);
accuracy = sum(YPred == YTest) / numel(YTest) * 100;
fprintf('\n==========================================\n');
fprintf('Final Validation Accuracy: %.2f%%\n', accuracy);
fprintf('==========================================\n');