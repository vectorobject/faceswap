### [English]|[中文](README_zh.md)


## **A UI for [roop](https://github.com/s0md3v/roop)**

### **Features:**

#### 1. Support for images, gifs, videos

#### 2. Allows swapping faces with specified faces

![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/main.png?raw=true)




### **First run:**




#### 1. Make sure the [roop project](https://github.com/s0md3v/roop)(version: 1.3.2) can run successfully.



#### 2. Create a new folder, e.g., `E:\ff` (this path will be used throughout the instructions).



#### 3. Download the [faceswap release version](https://github.com/vectorobject/faceswap/releases) and extract it to the folder: `E:\ff\faceswap`



#### 4. Copy the `server.py` from the source code to the root directory of the roop project



#### 5. Copy the `runServer.bat` from the source code to `E:\ff\runServer.bat`



#### 6. Modify the `runServer.bat` according to your environment



##### For example, if you are using minoconda installed at `G:\minoconda3\` , the content should be as follows:



```bat
chcp 65001>nul
call G:\miniconda3\Scripts\activate.bat G:\miniconda3
call conda activate roop
pushd D:\roop\roop
python -u server.py %1
```


##### The %1 represents the local server port number.

##### You can use other methods as well as long as server.py runs correctly.



#### 7. Run `E:\ff\fceswap\fceswap.exe`



##### If successful, a command prompt window will appear upon startup, as shown below:



![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/runserver.png?raw=true)



##### If any other errors appear, check the configuration based on the provided instructions.






### **Usage:**

![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/demo.gif?raw=true)



#### 1. Place your preferred images in `E:\ff\images`


#### 2. Double-click to select the source and target image (or GIF/video)


#### 3. Click [Detect Faces] for each image and wait for the faces to be marked


##### For GIFs or videos, clicking [Detect Faces] will capture frames at the current time point and then mark the faces. This allows extracting faces from multiple time points.


#### 4. Double-click the faces you want to swap;they will be added to the list on the right.


#### 5. Drag and adjust the order of faces in the list.


#### 6. Click [Generate] to create the face-swapped result.





### **Debuging Python scripts:**



#### 1. Create a file: `E:\ff\server_port.txt`, and write a port number (53499) in the file.


#### 2. Run `server.py` in debug mode using an IDE.


#### 3. Run `E:\ff\fceswap\fceswap.exe`