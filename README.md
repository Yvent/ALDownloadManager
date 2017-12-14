# ALDownloadManager
A progressive download manager for Alamofire （Alamofire下载器）


 
Sequential Download（顺序下载 ）

 ![image](https://github.com/Yvent/ALDownloadManager/blob/master/Resource/2017-12-11%2011_49_36.gif)  

Downloading at the same time （同时下载）

 ![image](https://github.com/Yvent/ALDownloadManager/blob/master/Resource/2017-12-11%2011_50_44.gif)



Requirements
 ````
iOS 9.0+ 
Xcode 8.0+
Swift 3.0+
 ````
 pod 'Alamofire'
 
 Add AlamofireExtension.swift,ALDownloadManager.swift,ALDownloadInfo.swift to the project 
 （将  AlamofireExtension.swift,ALDownloadManager.swift,ALDownloadInfo.swift 3个文件加入项目中）
 
Single file download （单文件下载）
 ````
ALDownloadManager.shared.download(url: self.testUrl)?.downloadProgress(nil).downloadResponse(nil)
                    
````
Multi file download at the same time （多文件同时下载）
 ````
ALDownloadManager.shared.changeDownloadState()
````
Multi file sequential downloads （多文件顺序下载）
````
ALDownloadManager.shared.changeWaitState(completeClose: nil)
````
