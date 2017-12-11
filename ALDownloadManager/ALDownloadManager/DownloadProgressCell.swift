//
//  DownloadProgressCell.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/9.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class DownloadProgressCell: UITableViewCell {
    
    
    var downloadurl: String?{
        didSet {
            self.fileNameLab.text = (downloadurl! as NSString).lastPathComponent
            let info = ALDownloadManager.shared.downloadInfoForURL(url: downloadurl)
            parseDownloadInfo(info: info)
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    func didDownloadBtn()  {
        let info = ALDownloadManager.shared.downloadInfoForURL(url: self.downloadurl)
        if info?.state == ALDownloadState.Download {
            ALDownloadManager.shared.suspend(url: self.downloadurl)
        }else if  info?.state == ALDownloadState.Cancel || info?.state == ALDownloadState.None  {
            ALDownloadManager.shared.download(url: self.downloadurl)
        }else if  info?.state == ALDownloadState.Wait  {
            ALDownloadManager.shared.download(url: self.downloadurl)
        }
    }
    func parseDownloadInfo(info: ALDownloadInfo?) {
        info?.progressChangeBlock = { (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            self.progressView.progress = (completed/total)
        }
        info?.stateChangeBlock = { [weak self] state in
            self?.parseDownloadState(state: state)
        }
        self.parseDownloadState(state: info?.state)
    }
    func parseDownloadState(state: ALDownloadState?)  {
        if state == ALDownloadState.Download {
            self.downloadBtn.setImage(UIImage(named: "pause"), for: .normal)
        }else if  state == ALDownloadState.Cancel || state == ALDownloadState.None  {
            self.downloadBtn.setImage(UIImage(named: "download"), for: .normal)
        }else if  state == ALDownloadState.Wait  {
            self.downloadBtn.setImage(UIImage(named: "clock"), for: .normal)
        }else if  state == ALDownloadState.Completed  {
            self.downloadBtn.setImage(UIImage(named: "check"), for: .normal)
        }
    }
}
