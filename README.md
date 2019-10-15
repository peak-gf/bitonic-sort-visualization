# bitonic-sort-visualization
A python script which helps visualize the sorting routine of bitonic sort (executed in parallel using nvcc).


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Things you need to install and how to install them

```
CUDA
```
go to : https://developer.nvidia.com/cuda-downloads

  *** Make sure that nvcc is working after the installation, else you're missing something!
  ```
  nvcc -arch=sm_30 bitonic_sort.cu 
  ```
  should compile.
  
```
ffmpeg           =>   sudo apt-get install -y ffmpeg
```
required to create video of visualization


```
pandas           =>   python3 -m pip install pandas
numpy            =>   python3 -m pip install numpy
matplotlib       =>   python3 -m pip install matplotlib
seaborn          =>   python3 -m pip install seaborn
```

### Installing

A step by step series of examples that tell you have to get the script running

Download the project

```
Download the project from github and put it inside a folder
```

Run the project

```
simply run python3 visualize.py
```
you'll see a video file generated within the same.

## Built With

* [Python3.6](https://www.python.org/downloads/release/python-360/) - Visualization
* [nvcc](http://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html) - Sorting

## Acknowledgments

* the original code for bitonic sort is taken from the following gist (https://gist.github.com/mre/1392067)
* email me for any querries : anujsingh9710@gmail.com
