//
//  DownloadProgressCell.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/9.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class DownloadProgressCell: UITableViewCell {
    
    var model: ALDownloadInfo! {
        didSet {
            parseDownloadInfo(info: model)
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
        if model.state == ALDownloadState.Download {
            model.resume()
        }else if model.state == ALDownloadState.Resume || model.state == ALDownloadState.None  {
            model.download()
        }else if model.state == ALDownloadState.Wait  {
             model.download()
        }
    }
    
    func parseDownloadInfo(info: ALDownloadInfo) {
        weak var weakself = self
        info.downloadProgress({ (progress) in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            weakself?.progressView.progress = (completed/total)
        })
        info.stateChangeBlock = { state in
            weakself?.parseDownloadState(state: state)
        }
        parseDownloadState(state: info.state)
    }
    
    func parseDownloadState(state: ALDownloadState?)  {
        if state == ALDownloadState.Download {
            downloadBtn.setImage(UIImage(named: "pause"), for: .normal)
        }else if state == ALDownloadState.Resume || state == ALDownloadState.None  {
            downloadBtn.setImage(UIImage(named: "download"), for: .normal)
        }else if state == ALDownloadState.Wait  {
            downloadBtn.setImage(UIImage(named: "clock"), for: .normal)
        }else if state == ALDownloadState.Completed  {
            downloadBtn.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
}
