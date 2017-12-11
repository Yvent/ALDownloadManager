//
//  SingleFileDownloadVC.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/8.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class SingleFileDownloadVC: UIViewController{
    
    let testUrl: String = "http://song.paohaile.com/30854966.mp3"
    
    let progressView: UIProgressView = {
        let view = UIProgressView()
        view.tintColor = UIColor.blue
        view.progress = 0
        return view
    }()
    let progressLab: UILabel = {
        let lab = UILabel()
        lab.text = "0"
        lab.textColor = UIColor.blue
        return lab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI() {
        self.view.backgroundColor = UIColor.white
        addNavRightItem()
        progressView.frame = CGRect(x: 20, y: ScreenHeight/2, width: ScreenWidth-40, height: 10)
        progressLab.frame = CGRect(x: 20, y: ScreenHeight/2-40, width: ScreenWidth-40, height: 30)
        self.view.addSubview(progressLab)
        self.view.addSubview(progressView)
    }
    func addNavRightItem() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(navRightItemClicked), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc func navRightItemClicked()  {
        inputUrl()
    }
    
    func inputUrl() {
        let alertVC = UIAlertController(title: "新建下载任务", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertVC.addTextField { (tf) in
            tf.placeholder = "\(self.testUrl)"
        }
        let acSure = UIAlertAction(title: "下载", style: .default) { (sureact) in
            if  let downloadUrl = alertVC.textFields?.first?.text , downloadUrl != ""{
                if let info = ALDownloadManager.shared.download(url: downloadUrl) {
                    info.progressChangeBlock = { (progress) in
                        let completed: Float = Float(progress.completedUnitCount)
                        let total: Float = Float(progress.totalUnitCount)
                        self.progressView.progress = (completed/total)
                        self.progressLab.text = "\(completed/total)"
                    }
                }else{
                    self.alTip()
                }
            }else{
                if let info = ALDownloadManager.shared.download(url: self.testUrl) {
                    info.progressChangeBlock = { (progress) in
                        let completed: Float = Float(progress.completedUnitCount)
                        let total: Float = Float(progress.totalUnitCount)
                        self.progressView.progress = (completed/total)
                        self.progressLab.text = "\(completed/total)"
                    }
                }else{
                    self.alTip()
                }
            }
        }
        let acCancel = UIAlertAction(title: "取消", style: .cancel) { (sureact) in }
        alertVC.addAction(acSure)
        alertVC.addAction(acCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alTip() {
        let alertVC = UIAlertController(title: "请勿重复下载", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let acCancel = UIAlertAction(title: "知道了", style: .cancel) { (sureact) in }
        alertVC.addAction(acCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}
