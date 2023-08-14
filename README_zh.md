### [English](README.md)|[中文]


## **一个给[roop](https://github.com/s0md3v/roop)做的UI**


### **特点：**

#### 1、支持图像、gif、视频

#### 2、支持换指定的脸

![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/main.png?raw=true)



### **首次运行步骤：**


#### 1、确保能正常运行[roop项目](https://github.com/s0md3v/roop)（版本：1.3.2）

#### 2、新建一个文件夹，例如：`E:\ff` （以下全部用此路径作为示例）

#### 3、下载[faceswap release版](https://github.com/vectorobject/faceswap/releases)，并将其解压缩到文件夹： `E:\ff\faceswap`

#### 4、将源码中的`server.py`复制到roop项目的根目录下

#### 5、将源码中的`runServer.bat`复制到`E:\ff\runServer.bat`

#### 6、请根据自己的环境修改`runServer.bat`

##### 例如我使用的是miniconda，安装路径是 `G:\miniconda3\`，那么内容如下：

```bat
chcp 65001>nul
call G:\miniconda3\Scripts\activate.bat G:\miniconda3
call conda activate roop
pushd D:\roop\roop
python -u server.py %1
```

##### 上面的%1是本地服务的端口号

##### 如果你使用其他的方法也可以，只要能正常运行`server.py`就行

#### 7.运行`E:\ff\faceswap\faceswap.exe`

##### 如果正常，启动后会弹出一个命令窗口，如下所示：

![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/runserver.png?raw=true)

##### 如果显示其他错误，请根据提示检查配置是否正确




### **使用方法：**
![](https://github.com/vectorobject/faceswap/blob/main/readme_assets/demo.gif?raw=true)

#### 1、在 `E:\ff\images\` 中放入你喜欢的图片

#### 2、双击选择源图片和目标图片（或GIF、视频）

#### 3、分别点击【识别人脸】，等待人脸被标记出来

##### 如果是GIF或者视频，点击【识别人脸】时会在当前时间点截图后再标记，可以从多个时间点提取人脸

#### 4、双击需要交换的人脸，它们会被添加到最右边的列表中

#### 5、拖动调整列表中人脸的顺序

#### 6、点击生成




### **调试python脚本：**

#### 1、新建一个文件：`E:\ff\server_port.txt`，文件内容是一个端口号（53499）

#### 2、IDE里以调试模式运行`server.py`

#### 3、运行`E:\ff\faceswap\faceswap.exe`


### **其它**

#### Flutter SDK 版本:3.10.4