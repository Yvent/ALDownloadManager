


import UIKit
import Alamofire


typealias ALDownloadCompleteClose = (_ info: ALDownloadInfo?) -> Void

class ALDownloadManager: NSObject {
    
    static let shared = ALDownloadManager()
    var manager: SessionManager?
    var downloadInfoArray: Array<ALDownloadInfo>?

    
    var completeClose: ALDownloadCompleteClose?
    
    
    fileprivate override init() {
        super.init()
        downloadInfoArray = Array<ALDownloadInfo>()
        let configuration = URLSessionConfiguration.default
        //请求超时
        configuration.timeoutIntervalForRequest = 5
        /** 最大同时下载数 ---- iOS对于同一个IP服务器的并发最大默认为4，OS X为6 */
        configuration.httpMaximumConnectionsPerHost = 10
        manager = Alamofire.SessionManager(configuration: configuration)
        ALDownloadNoteCenter.addObserver(self, selector: #selector(taskComplete(notification:)),name: Notification.Name.Info.DidComplete, object: nil)
    }
    
    
    /**  下载 */
    @discardableResult 
    func download(url: String?) -> ALDownloadInfo?{
        let info = self.downloadInfoForURL(url: url)
        info?.download()
        return info
    }
    
    /**  暂停下载 */
    func suspend(url: String?) {
        let info = self.downloadInfoForURL(url: url)
        info?.cancel()
    }
    /**  移除下载任务 */
    func remove(url: String) {
        self.removeInfoForURL(url: url)
    }
    /**  暂停所有 */
    func suspendAll() {
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Cancel || info.state == ALDownloadState.Completed {}
            else{
                info.cancel()
            }
            return info
        })
    }
    /**  恢复所有 */
    func resumeAll(){
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Download || info.state == ALDownloadState.Completed {}
            else{
                info.download()
            }
            return info
        })
    }
    
    /**  让第一个等待下载的文件开始下载 */
    func resumeFirstWillResume() {
        let willInfo = self.downloadInfoArray?.first(where: { (info) -> Bool in
            info.state == ALDownloadState.Wait
        })
        willInfo?.download()
    }
    /**  移除所有下载 */
    func removeAll(urls: Array<String>) {
        urls.forEach { (url) in
            remove(url: url)
        }
    }
    
    /**  获取下载信息 */
    func downloadInfoForURL(url: String?) -> ALDownloadInfo? {
        if let info = self.downloadInfoArray?.filter({ (info) -> Bool in
            info.downloadurl == url
        }).first {
            return info
        }else{
            let info = ALDownloadInfo(manager: manager, destinationPath: nil, url: url)
            self.downloadInfoArray?.append(info)
            return info
        }
    }
    /**  将所有未下载完成的任务改变为等待下载 */
    func changeWaitState(completeClose: ALDownloadCompleteClose?) {
        self.completeClose = completeClose
            var isDownloadFirst = false
            self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
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
    func changeDownloadState() {
        self.downloadInfoArray = self.downloadInfoArray?.map({ (info) -> ALDownloadInfo in
            if  info.state == ALDownloadState.Download || info.state == ALDownloadState.Completed{}
            else{
                info.download()
            }
            return info
        })
    }
    /**  下载完成通知 */
    func taskComplete(notification: Notification)  {
        if let info = notification.userInfo, let url = info["url"] as? String {
            let info = downloadInfoForURL(url: url)
            info?.state = ALDownloadState.Completed
            if let close = self.completeClose {
                 close(info)
            }
            resumeFirstWillResume()
        }
    }
    /**  移除下载信息 */
    func removeInfoForURL(url: String)  {
        if let info = self.downloadInfoArray?.filter({ (info) -> Bool in
            info.downloadurl == url
        }).first {
            info.remove()
            if let alindex = self.downloadInfoArray?.index(of: info) {
                self.downloadInfoArray?.remove(at: alindex)
            }
        }
    }
    /**  移除通知 */
    deinit{
        ALDownloadNoteCenter.removeObserver(self)
    }
}
