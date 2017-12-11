//
//  AlamofireExtension.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/13.
//  Copyright © 2017年 YV. All rights reserved.
//

import Foundation
import Alamofire



extension DownloadRequest {
    
    func downloadProgressValue(value: @escaping (Float)->())  {
        self.downloadProgress { (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            
            value(completed/total)
        }
    }

}


/* 通知 begin */
let ALDownloadNoteCenter = NotificationCenter.default
let ALDownloadedFolderName = "ALDownloadedFolder"

extension Notification.Name {
    public struct Info {
        
        public static let DidResume = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didResume")
        
        public static let DidSuspend = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didSuspend")

        public static let DidCancel = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didCancel")

        //完成下载通知
        public static let DidComplete = Notification.Name(rawValue: "ALDownloadManager.notification.Info.state.didComplete")
    }
}
/* 通知 end */
