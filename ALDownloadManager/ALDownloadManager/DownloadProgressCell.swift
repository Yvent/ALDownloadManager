//
//  DownloadProgressCell.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/9.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class DownloadProgressCell: UITableViewCell {
    
    var downloadInfoId: String!
    
    // TODO: 刷新会重复下载
    var downloadurl: String?{
        didSet {
            fileNameLab.text = (downloadurl! as NSString).lastPathComponent
            downloadInfoId = downloadurl
            ALDownloadInfo().download(url: downloadurl!, destinationPath: nil)
                .downloadProgress({ [weak self] (progress) in
                    
                    guard self?.downloadInfoId == self?.downloadurl else {
                        return
                    }
                    let completed: Float = Float(progress.completedUnitCount)
                    let total: Float = Float(progress.totalUnitCount)
                    self?.progressView.progress = (completed/total)
                }).downloadResponse { (response) in
                    print(response)
            }
        }
    }
    
    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.tintColor = UIColor.black
        view.progress = 0
        return view
    }()
    
    let fileNameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black
        return lab
    }()
    
    let downloadBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        fileNameLab.frame = CGRect(x: 10, y: (80-50)/2, width: ScreenWidth-100, height: 30)
        progressView.frame = CGRect(x: 10, y: 60, width: ScreenWidth-100, height: 10)
        downloadBtn.frame = CGRect(x: ScreenWidth-70, y: (80-50)/2, width: 50, height: 50)
        downloadBtn.addTarget(self, action: #selector(DownloadProgressCell.didDownloadBtn), for: .touchUpInside)
        self.addSubview(fileNameLab)
        self.addSubview(progressView)
        self.addSubview(downloadBtn)
    }
    
    @objc
    func didDownloadBtn()  {
        guard let info = ALDownloadManager.getInfoForURL(url: downloadurl) else {return}
        if info.state == ALDownloadState.Download {
            ALDownloadManager.suspend(url: downloadurl)
        }else if info.state == ALDownloadState.Cancel || info.state == ALDownloadState.None  {
            ALDownloadManager.download(url: downloadurl)
        }else if info.state == ALDownloadState.Wait  {
            ALDownloadManager.download(url: downloadurl)
        }
    }
    
    func parseDownloadInfo(info: ALDownloadInfo?) {
        info?.downloadProgress({ (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            self.progressView.progress = (completed/total)
        })
        info?.stateChangeBlock = { [weak self] state in
            self?.parseDownloadState(state: state)
        }
        parseDownloadState(state: info?.state)
    }
    
    func parseDownloadState(state: ALDownloadState?)  {
        if state == ALDownloadState.Download {
            downloadBtn.setImage(UIImage(named: "pause"), for: .normal)
        }else if state == ALDownloadState.Cancel || state == ALDownloadState.None  {
            downloadBtn.setImage(UIImage(named: "download"), for: .normal)
        }else if state == ALDownloadState.Wait  {
            downloadBtn.setImage(UIImage(named: "clock"), for: .normal)
        }else if state == ALDownloadState.Completed  {
            downloadBtn.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
}
