
# This script is translated from FindPolynyaIDs.m by ChatGTP.
# Many features here are not available and it runs slowly.
# so the MATLAB version may be a better choise

import numpy as np
import matplotlib as matplotlib
matplotlib.use('TkAGG')
import matplotlib.pyplot as plt
from scipy.io import loadmat

# Read the overview map
print("This script is translated from FindPolynyaIDs.m by ChatGTP.")
print("Many features here are not available and it runs slowly.")
print("so the MATLAB version may be a better choise")
path = input('Enter the path of OverviewMap.mat: ')
overview_map = loadmat(path)['OverviewMap']
overview_map_nan = np.copy(overview_map)
overview_map_nan = np.double(np.isnan(overview_map_nan))
overview_map[np.isnan(overview_map)] = 0
polynya_ids = np.unique(overview_map)

# Rename the polynya IDs
polynya_location = np.mod(polynya_ids[1:], 10000000) // 1000 / 10
polynya_location_i = np.argsort(polynya_location) + 1
polynya_location_i = np.insert(polynya_location_i, 0, 0)
overview_map_new = polynya_location_i[np.unique(overview_map, return_inverse=True)[1]].reshape(overview_map.shape)

# Plot robust extent
# overview_map_new[overview_map_new == 0] = np.nan
plt.figure(figsize=(10, 6))
h = plt.pcolor(overview_map_new, cmap='tab10')
plt.gca().invert_yaxis()
plt.colorbar(h)
plt.title('Polynya robust extent map\nPlease click the polynya whose ID you need')

# Get points
counts = 0
IDs = []
click_positions = []
while True:
    if counts > 0:
        plt.pause(0.01)
    click_position_temp = plt.ginput(1, timeout=-1)[0]
    click_x, click_y = int(round(click_position_temp[0])), int(round(click_position_temp[1]))
    ID_temp = overview_map[click_y, click_x]
    if ID_temp < 100:
        continue
    else:
        IDs.append(ID_temp)
        click_positions.append(click_position_temp)
        plt.plot(click_position_temp[0], click_position_temp[1], '+k')
        counts += 1
        plt.text(click_position_temp[0] + 10, click_position_temp[1] + 10, f'#{ID_temp:09}', color='k', fontsize=8)
        plt.draw()

plt.show()