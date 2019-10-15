import subprocess
import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import seaborn as sns
import time

# compile the sorting program with nvcc
subprocess.call(["nvcc", "bitonic_sort.cu", "-arch=sm_30"])
# execute the sorting program
subprocess.call("./a.out")

# read the generated sorting data
sort_data = pd.read_csv('tmp.csv')
ind = [x for x in range(len(sort_data.iloc[0]))]

# specify the video parameters
Writer = animation.writers['ffmpeg']
writer = Writer(fps=1, metadata=dict(artist='Anuj Singh'), bitrate=1800)

# specify figure parameters
fig = plt.figure(figsize=(24, 8))
plt.title('Bitonic Sort',fontsize=20)

# animation function
def animate(i):
    fig.clf()
    if i >= len(sort_data):
        i = len(sort_data)-1 
    data = sort_data.iloc[i]
    sns.barplot(x=ind, y=data) 

# animate the dataset
ani = matplotlib.animation.FuncAnimation(fig, animate, frames=(len(sort_data)+2), repeat=False)

# save the animation as an mp4
ani.save('Bitonic Sort.mp4', writer=writer)
