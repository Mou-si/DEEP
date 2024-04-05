# DEEP-AA getting started

[toc]

The dataset of Daily Edge of Each Polynyas in Antarctica (DEEP-AA) recorded the daily map of each Antarctica polynya. To create this dataset, we developed a novel polynya tracing and identification method. 

Here is the script to create and envaluate the DEEP-AA dataset. All these codes are writtern in MATLAB. Following is the tutorial to run these scripts, and the detailed document is coming soon.

## Creating the DEEP-AA dataset

### Preparing the data

What you need:

1. Daily open water map
2. Land mask
3. Air temperature (optional)
4. Landfast ice mask (optional)

To create the dataset, the daily open water map files and land mask are required. 

The open water maps can be obtained basing on sea ice concentrationg data or brightness temperature data by PSSM.
For the open water maps, it would be best if a binary matrix where 0 represents water and 1 represents ice can be provided directly. Onthe other hand, if you provide sea ice concentration data and thresholds, our code can also handle it.
But no matter what data is inputted, it should be ensured that the daily map is saved in a separate file, and the file name should be changed to an 8-digit number to represent the time (i.e. YYYYMMDD).
Our code supports the formats of NetCDF(.nc), HDF(.hdf), MATLAB formatted data(.mat).

*Tips: The grid of open water maps should preferably be in polar projection.*

**The land mask should be preprocessed** to fill the waters surrounded by land. You can use the script of [./CreateMasks/CreateLandMask.m](https://github.com/Mou-si/DEEP/blob/main/CreateMasks/CreateLandMask.m) to do the preprocessing.
The land mask should not change over time.

Air temperature and landfast ice masks are optional, but we recommend you input them.

Air temperature is used to judge season, which can avoid the very unstable polynyas in warmer season expand violently and bring errors.
The air temperature should also be 4 times a day (UTC00, 08, 12, 20), and in NetCDF file.
Each day's data is placed in a different file and marked with an 8-digit date, as the open water maps.

Landfast ice masks are used to improve the issues that passive microwave data are not good at distinguishing between fast ice, ice shelves, and thin ice areas.
Now our codes only supports [the land fast ice from Fraser](https://data.aad.gov.au/metadata/AAS_4116_Fraser_fastice_circumantarctic), which is semimonthly and in NetCDF files.
**The landfast ice masks should be interpolated before using.** You can use [./CreateMasks/CreateFastIceMask.m](https://github.com/Mou-si/DEEP/blob/main/CreateMasks/CreateFastIceMask.m).

### Setting the parameters

The parameters should be setted in the MATLAB code file (.m). You can see an example of [./NameList.m](https://github.com/Mou-si/DEEP/blob/main/NameList.m).
The file should be put together with the main codes.
The parameters for optional modes (Air temperature and Landfast ice mask) are in independent files, but they will be called in the main parameters setting file.

*Tips: the `clear all;` in the example file ([./NameList.m](https://github.com/Mou-si/DEEP/blob/main/NameList.m)) is necessary. DON'T change it.*

### Running the codes

Before running the codes please check if the switch of warning is on. All warnings in this program are ver important.

Now you should first find the path where you store the main codes of this program (the folder with FindPolynyaMain.m) and parameter settings. They should be in one position
If not, copy the parameter setting file to the directory of main codes.

Then open your MATLAB and change the directory to the directory of main codes.

``` MATLAB
cd [the directory of main codes]
```

Although our example parameter setting file (NameList.m) includes a command to empty the variables in memory, we also recommand you to initialize memory before running codes:
``` MATLAB
clear all;
```

Now you can run the code. All you have to do is call `FindPolynyaMain` and with the string of the name of parameter setting file:
``` MATLAB
FindPolynyaMain(['name of your parameter setting file'])
```
for example
``` MATLAB
FindPolynyaMain('NameList')
```

In defult, all figure windows will be closed and youe command wind will be cleared, when you run the `FindPolynyaMain`.
You can also change these settings if you don't like this.
``` MATLAB
FindPolynyaMain(___, 'clcFlag', 'off', 'closeFlag', 'off')
```

You can also choose to output the diary to the directory of main codes (there is no diary in defult). The diary will be named as Diary_[name of your parameter setting file].
``` MATLAB
FindPolynyaMain(___, 'diary', 'on')
```

Refer to the help for how to turn on/off them
``` MATLAB
help FindPolynyaMain
```

## Checking the output

The outputs of the code, i.e., the DEEP-AA dataset, are in NetCDF files. Each day's polynya extent map is placed in a separate file.
In our work, each polynya is given a unique ID that does not change over time. In each day's map, we mark the extent of the polynyas with thire IDs. In addition, the open sea, lands are also shown.
See details in the following table:

|Value|Element represented|
|---|---|
|NaN or -999|mask of lands|
|-100|mask of land fast ice from Fraser|
|-2|open sea|
|-1|the other open waters (not polynyas)|
|>0|ID masks of polynyas indicating the daily extents|

And the odd ID numbers indicates open-ocean polynyas and the even ID numbers are coastal.

In addiiton, we also output the input parameters to facilitate check (Input.txt).

And to easily find the polynya's IDs, the overview map is also provided (OverviewMap.mat). You can use the [./OverviewMapTool/PolynyaIDsFinder_Guide.m](https://github.com/Mou-si/DEEP/blob/main/OverviewMapTool/PolynyaIDsFinder_Guide.m) (with guide) or [./OverviewMapTool/PolynyaIDsFinder.m](https://github.com/Mou-si/DEEP/blob/main/OverviewMapTool/PolynyaIDsFinder.m) (without guide) to view the overview map and ask the IDs.
This tool has a GUI, you can easily do this with just clicks, and at last the results will be copied automatically.

Here is a movie abot how to use the PolynyaIDsFinder, and you can also see the [readme for this tool](https://github.com/Mou-si/DEEP/blob/main/OverviewMapTool/readme)

![PolynyaIDsFinderGuide](https://github.com/Mou-si/DEEP/blob/main/OverviewMapTool/PolynyaIDsFinderGuide.gif)

We also provide a [Python version](https://github.com/Mou-si/DEEP/blob/main/OverviewMapTool/PolynyaIDsFinder.py) of PolynyaIDsFinder for users who cannot use MATLAB. 
But this is translated using ChatGTP, so it is not only not as powerful as MATLAB, but also very slow.

The dataset has been evaluated by the codes in [./Evaulate](https://github.com/Mou-si/DEEP/tree/main/Evaluate).

<font size=7>_**Enjoy your DEEP-AA!**_</font>