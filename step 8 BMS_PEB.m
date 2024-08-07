
%%%%%% perform BMS of redcued PEB models and BMR and BMA analysis of winning model%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;
spm('defaults','EEG');

%%% go to place were DCM results are stored
cd  'C:/Users/Growth fire/Documents/research/signal/updated data/DCM/old/'
print_f = 0;
fold = dir(fullfile(['C:/Users/Growth fire/Documents/research/signal/updated data/DCM/old/*combined_results.mat']));
%%%% list of parameter to remove (see below)
%%% parameter B refers to the extrinsic connectio, B_G(1,:) to V1 intrinsic
%%% and B_G(2:3,:) intrinsic connections of V5
%remove_params = {{'B'} {'B_G(2:3,:)'} {'B_G(1,:)'} {'B' 'B_G(2:3,:)'} {'B' 'B_G(1,:)'} {'B_G(1,:)' 'B_G(2:3,:)'} {'B' 'B_G(1,:)' 'B_G(2:3,:)'}}
%%%% labels for plotting the free energies of the reduced PEB models
% x_labels={'FULL' 'V5+V1' 'Ext+V1' 'Ext+V5' 'V1' 'V5' 'Ext' 'Null'}
remove_params = {{'A'} {'A(2:3,:)'} {'A(1,:)'} {'A' 'A(2:3,:)'} {'A' 'A(1,:)'} {'A(1,:)' 'A(2:3,:)'} {'A' 'A(1,:)' 'A(2:3,:)'}};
x_labels ={'Constant''DCT1' 'DCT2' 'DCT3' 'Decay'};
threshold = 5;

%% get the DCM analysis for PEB
clear HCM;
HCM = {};  % Initialize HCM as an empty cell array
tel = 0;
for isub = 1:length(fold)
  load(fold(isub).name)
  disp(isub);
  %%% check explained variance and skip of explained variance is not good. 
  expl_d(isub)=explained_var_dcm(DCM)
  if expl_d(isub)> threshold
    tel = tel+1
    HCM{tel,1} =DCM;
  else
    disp(['File ', fold(isub).name, ' skipped due to low explained variance']);%debug
  end
end

%% Check if HCM is populated correctly Debug
if isempty(HCM)
    error('No valid DCM models found with explained variance > 50.');
else
    disp(['Number of valid DCM models: ', num2str(length(HCM))]);
end
%% define reduced models, we only need 1 DCM to do this
clear models
models{1} = DCM;%%% here i put yhe full model
for iparam = 1:length(remove_params)
    DCMtmp = DCM;
    id = spm_find_pC(DCM.Cp,DCM.Ep,remove_params{iparam})

    Mparam = spm_vec(DCMtmp.M.pE);
    Cparam = spm_vec(DCMtmp.M.pC);
    %%% set reduced priors
    Mparam(id) = 0;
    Cparam(id) = 0
    DCMtmp.M.pE = spm_unvec(Mparam,DCMtmp.M.pE);
    DCMtmp.M.pC = spm_unvec(Cparam,DCMtmp.M.pC);
    models{iparam+1} =DCMtmp;
end

%% Check if models array is populated correctly
if isempty(models)
    error('Models array is empty. No models to process.');
else
    disp(['Number of models: ', num2str(length(models))]);
    for i = 1:length(models)
        disp(['Model ', num2str(i), ':']);
        disp(fieldnames(models{i}));
    end
end

%% full model PEB
PEB = spm_dcm_peb(HCM,[],{'B' 'B_G'})
if isempty(PEB)
    error('PEB model could not be computed.');
else
    disp('PEB model successfully computed.');
end
%% BMR of reduced model definition from previous sections
[bma,bmr]=spm_dcm_peb_bmc(PEB,models)
if isempty(bma) || isempty(bmr)
    error('BMA or BMR could not be computed.');
else
    disp('BMA and BMR successfully computed.');
end

close all;
%% get the free energies of the reduced models and plot
for i = 1:8
  F(i)=bmr{i}.F;
end
%%% plot the fee energies
bar(F)
x_labels={'FULL' 'V5+V1' 'Ext+V1' 'Ext+V5' 'V1' 'V5' 'Ext' 'Null'}
set(gca,'XTickLabel', x_labels);
set(gca,'XTickLabelRotation',70)
set(gca,'FontSize',30)
xlabel('Model')
ylabel('F-difference')
set(gcf,'Position',[68 1 1853 1090])

%%% perform greedy search and BMA of the winning model
BMA = spm_dcm_peb_bmc(PEB)
if isempty(BMA)
    error('BMA could not be computed.');
else
    disp('BMA successfully computed.');
end
 
 
 
 
