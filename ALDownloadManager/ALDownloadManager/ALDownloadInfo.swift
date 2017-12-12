


import Alamofire


public enum ALDownloadState: Int {
    case None = 0  // 闲置状态
    case Download = 1  // 开始下载
    //    case Suspened = 2 // 暂停下载
    case Cancel = 3 // 取消下载
    case Wait = 4 // 等待下载
    case Completed = 5 // 完成下载
    
}

typealias ALDownloadStateBlock = (_ state: ALDownloadState)-> Void
typealias ALDownloadProgressBlock = (_ progress: Progress)-> Void
typealias ALDownloadResponseBlock = (_ response: DefaultDownloadResponse)-> Void


class ALDownloadInfo: NSObject {
    
    open let downloadurl: String?
    /**  下载请求  */
    var downloadRequest: DownloadRequest?
    /**  取消下载时的数据  */
    var cancelledData: Data?
    /**  下载管理者  */
    open let manager: SessionManager?
    /**  文件下载路径  */
    open let destinationPath: String?
    /**  下载状态改变时调用  */
    var stateChangeBlock: ALDownloadStateBlock?
    /**  返回下载进度  */
    var progressChangeBlock: ALDownloadProgressBlock?
    var responsChangeBlock: ALDownloadResponseBlock?
    
    var state: ALDownloadState? = ALDownloadState.None {
        willSet{
            if let stateBlock = self.stateChangeBlock,let newState = newValue {
                DispatchQueue.main.async {stateBlock(newState)}
            }
        }
        didSet{}
    }
    private var progress: Progress? {
        willSet{
            if let progressBlock = self.progressChangeBlock,let newProgress = newValue {
                DispatchQueue.main.async {progressBlock(newProgress)}
            }
        }
        didSet{}
    }
    private var respons: DefaultDownloadResponse? {
        willSet{
            if let responsBlock = self.responsChangeBlock,let newProgress = newValue {
                DispatchQueue.main.async {responsBlock(newProgress)}
            }
        }
        didSet{}
    }
    
    init(manager: SessionManager?, destinationPath: String?, url: String? ) {
        self.manager = manager
        self.destinationPath = destinationPath
        self.downloadurl = url
    }
    
    func download() {
        if let resumeData = cancelledData {
            let destination = createDestination(destinationPath: destinationPath)
            downloadRequest = manager?.download(resumingWith: resumeData, to: destination).response(completionHandler: { [weak self] (defresponse) in
                self?.cancelledData = defresponse.resumeData
            }).downloadProgress(closure: { (progress) in
                self.progress = progress
            }).response(completionHandler: { (defaultResponse) in
                self.respons = defaultResponse
            })
        }else{
            let destination = createDestination(destinationPath: destinationPath)
            if let url = downloadurl {
                downloadRequest = manager?.download(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).response(completionHandler: { [weak self] (defresponse) in
                    self?.cancelledData = defresponse.resumeData
                }).downloadProgress(closure: { (progress) in
                    self.progress = progress
                }).response(completionHandler: { (defaultResponse) in
                    self.respons = defaultResponse
                })
            }
        }
        self.state = ALDownloadState.Download
    }
    func cancel() {
        downloadRequest?.cancel()
        self.state = ALDownloadState.Cancel
    }
    /**  挂起 */
    func hangup() {
        downloadRequest?.cancel()
        self.state = ALDownloadState.Wait
    }
    
    func remove() {
        downloadRequest?.cancel()
        self.state = ALDownloadState.None
    }
    @discardableResult
    func downloadProgress(_ progress: ALDownloadProgressBlock?) -> Self  {
        self.progressChangeBlock = progress
        return self
    }
    @discardableResult
    func downloadResponse(_ response: ALDownloadResponseBlock?) -> Self {
        self.responsChangeBlock = response
        return self
    }
    /**  创建文件下载完成的储存位置
     *    destinationPath = nil 时会在Documents下创建ALDownloadedFolder文件夹
     */
    func createDestination(destinationPath: String?) -> DownloadRequest.DownloadFileDestination {
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = destinationPath == nil ? documentsURL.appendingPathComponent(ALDownloadedFolderName, isDirectory: true).appendingPathComponent(response.suggestedFilename!) : URL(fileURLWithPath: destinationPath!)
            ALDownloadNoteCenter.post(name: Notification.Name.Info.DidComplete, object: self, userInfo: ["url": self.downloadurl!])
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return destination
    }
}
