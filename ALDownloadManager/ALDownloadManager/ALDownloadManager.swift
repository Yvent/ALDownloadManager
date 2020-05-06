import UIKit
import Alamofire

typealias ALDownloadCompleteClose = (_ info: ALDownloadInfo?) -> Void

class ALDownloadManager: NSObject {
    
    static let shared = ALDownloadManager()
    
    let manager: Session
    
    private var downloadInfos = Array<ALDownloadInfo>()
    
    private var completeClose: ALDownloadCompleteClose?
    
    fileprivate override init() {
        let configuration = URLSessionConfiguration.default
        //请求超时
        configuration.timeoutIntervalForRequest = 5
        // 最大同时下载数 ---- iOS对于同一个IP服务器的并发最大默认为4，OS X为6
        configuration.httpMaximumConnectionsPerHost = 10
        
        manager = Alamofire.Session(configuration: configuration)
        super.init()
        ALDownloadNoteCenter.addObserver(self, selector: #selector(taskComplete(notification:)),name: Notification.Name.Info.DidComplete, object: nil)
    }
    
    
    /**  下载 */
    @discardableResult 
    static func download(url: String?) -> ALDownloadInfo?{
        let info = getInfoForURL(url: url)
//        info?.download()
        return info
    }
    
    /**  暂停下载 */
     static func suspend(url: String?) {
        let info = getInfoForURL(url: url)
        info?.cancel()
    }
    
    /**  移除下载任务 */
    static func remove(url: String) {
//        removeInfoForURL(url: url)
    }
    
    /**  暂停所有 */
    static func suspendAll() {
        shared.downloadInfos = shared.downloadInfos.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Cancel || info.state == ALDownloadState.Completed {}
            else{
                info.cancel()
            }
            return info
        })
    }
    
    /**  恢复所有 */
    static func resumeAll(){
        shared.downloadInfos = shared.downloadInfos.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Download || info.state == ALDownloadState.Completed {
                print("Download or Completed")
            }
            else{
//                info.download()
            }
            return info
        })
    }
    
    /**  让第一个等待下载的文件开始下载 */
    static func resumeFirstWillResume() {
        let willInfo = shared.downloadInfos.first(where: { (info) -> Bool in
            info.state == ALDownloadState.Wait
        })
//        willInfo?.download()
    }
    
    /**  移除所有下载 */
    static func removeAll(urls: Array<String>) {
        urls.forEach { (url) in
            remove(url: url)
        }
    }
    
    static func multipleDownload(urls: Array<String>) {
        let updateGroup = DispatchGroup()
        for item in urls {
            updateGroup.enter()
            print("enter")
            let dinfo = download(url: item)
            dinfo?.downloadProgress({ (progress) in
                print("=====\(progress)=====")
                let completed: Float = Float(progress.completedUnitCount)
                let total: Float = Float(progress.totalUnitCount)
                let progressValue = (completed/total)
                print(progressValue)
                if progressValue == 1 {
                    print("leave")
                     updateGroup.leave()
                }
            })
        }
        updateGroup.notify(queue: .global()) {
            print("所有的任务执行完了===")
        }
    }
    
    /// 按顺序下载
//    static func sssss(urls: Array<String>)  {
//        let semaphore = DispatchSemaphore(value: 1)
//        var images = Array<UIImage>()
//        for item in urls {
//            semaphore.wait()
//            let dinfo = download(url: item)
//            dinfo?.downloadProgress({ (progress) in
//                print("=====\(progress)=====")
//                let completed: Float = Float(progress.completedUnitCount)
//                let total: Float = Float(progress.totalUnitCount)
//                let progressValue = (completed/total)
//                print(progressValue)
//                if progressValue == 1 {
//                    print("leave")
//                    semaphore.signal()
//                }
//            })
//        }
//        return images
//    }
    
    /**  获取下载信息 */
     static func getInfoForURL(url: String?) -> ALDownloadInfo? {
//        if let info = shared.downloadInfos.filter({ (info) -> Bool in
//            info.downloadurl == url
//        }).first {
//            return info
//        }else {
//            return nil
//        }
//        else{
//            let info = ALDownloadInfo(manager: shared.manager, destinationPath: nil, url: url)
//            shared.downloadInfos.append(info)
//            return info
//        }
        return nil
    }
    
    /**  将所有未下载完成的任务改变为等待下载 */
    static func changeWaitState(completeClose: ALDownloadCompleteClose?) {
        shared.completeClose = completeClose
        var isDownloadFirst = false
        shared.downloadInfos = shared.downloadInfos.map({ (info) -> ALDownloadInfo in
            if isDownloadFirst == false {
                if info.state == ALDownloadState.Download {
                    isDownloadFirst = true
                    return info
                }
            }
            if info.state == ALDownloadState.Completed {}
            else{
                info.hangup()
            }
            return info
        })
        if isDownloadFirst == false {
            resumeFirstWillResume()
        }
    }
    
    /**  将所有未下载完成的任务改变为正在下载 */
   static func changeDownloadState() {
        shared.downloadInfos = shared.downloadInfos.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Download || info.state == ALDownloadState.Completed{}
            else{
//                info.download()
            }
            return info
        })
    }
    
    /**  下载完成通知 */
    @objc
    func taskComplete(notification: Notification)  {
        if let info = notification.userInfo, let url = info["url"] as? String {
            let info = ALDownloadManager.getInfoForURL(url: url)
            info?.state = ALDownloadState.Completed
            if let close = completeClose {
                close(info)
            }
            ALDownloadManager.resumeFirstWillResume()
        }
    }
    
    /**  移除下载信息 */
//    static func removeInfoForURL(url: String)  {
//        if let info = shared.downloadInfos.filter({ (info) -> Bool in
//            info.downloadurl == url
//        }).first {
//            info.remove()
//            if let alindex = shared.downloadInfos.firstIndex(of: info) {
//                shared.downloadInfos.remove(at: alindex)
//            }
//        }
//    }
    
    /**  移除通知 */
    deinit{
        ALDownloadNoteCenter.removeObserver(self)
    }
    
}

