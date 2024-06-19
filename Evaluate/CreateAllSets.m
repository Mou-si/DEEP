clear all; clc; close all; fclose all;
cd C:\Users\13098\Documents\冰间湖识别\Scrip

%% 3.125km
copyfile('./FastIceMask/FastIceParameter_3125km.m', './FastIceMask/FastIceParameter.m')

FindPolynyaMain('NameList_3125')

%% 6.25km
copyfile('./FastIceMask/FastIceParameter_625km.m', './FastIceMask/FastIceParameter.m')

% SIC
FindPolynyaMain('NameList_DailyTracem')
FindPolynyaMain('NameList_DailyTracep')
FindPolynyaMain('NameList_NoFastIce')
FindPolynyaMain('NameList_SIC50')
FindPolynyaMain('NameList_SIC60')
FindPolynyaMain('NameList_SIC70')
FindPolynyaMain('NameList_SIC80')
FindPolynyaMain('NameList_YearlyTracem')
FindPolynyaMain('NameList_YearlyTracep')

%% 12.5km
copyfile('./FastIceMask/FastIceParameter_125km.m', './FastIceMask/FastIceParameter.m')

% SIC
FindPolynyaMain('NameList_12500')

% PSSM
FindPolynyaMain('NameList_AMSR36_PSSM')
FindPolynyaMain('NameList_AMSR36_PSSM_10d')
FindPolynyaMain('NameList_AMSR36_PSSM_20d')
FindPolynyaMain('NameList_AMSR36_PSSM_70')
FindPolynyaMain('NameList_AMSR36_PSSM_75')
FindPolynyaMain('NameList_AMSR36_PSSM_80')
FindPolynyaMain('NameList_AMSR36_PSSM_DailyTracem')
FindPolynyaMain('NameList_AMSR36_PSSM_DailyTracep')
FindPolynyaMain('NameList_AMSR36_PSSM_NoFastIce')
FindPolynyaMain('NameList_AMSR36_PSSM_YearlyTracem')
FindPolynyaMain('NameList_AMSR36_PSSM_YearlyTracep')

%% 25km
copyfile('./FastIceMask/FastIceParameter_25km.m', './FastIceMask/FastIceParameter.m')

% PSSM
FindPolynyaMain('NameList_25000')
FindPolynyaMain('NameList_AMSR36_PSSM_25km')