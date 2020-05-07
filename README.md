# ALDownloadManager
A progressive download manager for Alamofire

 顺序下载 

 ![image](https://github.com/Yvent/ALDownloadManager/blob/master/Resource/2017-12-11%2011_49_36.gif)  

同时下载

 ![image](https://github.com/Yvent/ALDownloadManager/blob/master/Resource/2017-12-11%2011_50_44.gif)



Requirements
 ````
iOS 10.0+ 
Xcode 11.0+
Swift 5.0+
 ````
 pod 'Alamofire', '~> 5.1' 
 将  AlamofireExtension.swift,ALDownloadInfo.swift 3个文件加入项目中

 文件下载
 ````
 ALDownloadInfo(url: url).download().downloadProgress { (progress) in
            print(progress)
 }
                    
 ````
 多文件同时下载见demo MultipleFilesDownloadSTVC.swift 



