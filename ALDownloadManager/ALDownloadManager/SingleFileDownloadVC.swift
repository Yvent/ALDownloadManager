//
//  SingleFileDownloadVC.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/8.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class SingleFileDownloadVC: UIViewController {
    
    let testUrl: String = "https://central.github.com/deployments/desktop/desktop/latest/darwin"
    
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
    
    let suspendedBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("suspended", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitle("download", for: .selected)
        btn.backgroundColor = UIColor.lightGray
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initUI() {
        view.backgroundColor = UIColor.white
        addNavRightItem()
        progressView.frame = CGRect(x: 20, y: ScreenHeight/2, width: ScreenWidth-40, height: 10)
        progressLab.frame = CGRect(x: 20, y: ScreenHeight/2-40, width: ScreenWidth-40, height: 30)
        suspendedBtn.frame = CGRect(x: 20, y: ScreenHeight/2+40, width: 100, height: 40)
        view.addSubview(progressLab)
        view.addSubview(progressView)
        view.addSubview(suspendedBtn)
        suspendedBtn.addTarget(self, action: #selector(didSuspendedBtn(_:)), for: .touchUpInside)
    }
    
    func addNavRightItem() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(navRightItemClicked), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc
    func navRightItemClicked()  {
        inputUrl()
    }
    
    @objc
    func didSuspendedBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            ALDownloadManager.suspendAll()
            
        }else{
            
            ALDownloadInfo().download(url: testUrl, destinationPath: nil)
                .downloadProgress({ (progress) in
                    let completed: Float = Float(progress.completedUnitCount)
                    let total: Float = Float(progress.totalUnitCount)
                    self.progressView.progress = (completed/total)
                    self.progressLab.text = "\(completed/total)"
                }).downloadResponse { (response) in
                    print(response)
            }
            
            
        }
    }
    
    func inputUrl() {
        
        let alertVC = UIAlertController(title: "新建下载任务", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertVC.addTextField { (tf) in
            tf.placeholder = "\(self.testUrl)"
        }
        
        let acSure = UIAlertAction(title: "下载", style: .default) { (sureact) in
            if  let downloadUrl = alertVC.textFields?.first?.text , downloadUrl != ""{
                
                if let info = ALDownloadManager.download(url: downloadUrl) {
                    info.progressChangeBlock = { (progress) in
                        let completed: Float = Float(progress.completedUnitCount)
                        let total: Float = Float(progress.totalUnitCount)
                        self.progressView.progress = (completed/total)
                        self.progressLab.text = "\(completed/total)"
                    }
                    
                    info.downloadResponse({ (reponse) in
                        print("\(reponse.error.debugDescription)")
                    })
                }else{
                    self.alTip()
                }
            }else{
                if let info = ALDownloadManager.download(url: self.testUrl) {
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
        let alertVC = UIAlertController(title: "请勿重复下载", message: nil, preferredStyle: UIAlertController.Style.alert)
        let acCancel = UIAlertAction(title: "知道了", style: .cancel) { (sureact) in }
        alertVC.addAction(acCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}


extension UIView {
    
    
    
    func downLoad(url: String, progressBlock: @escaping ((Float) -> Void))  {
        
        ALDownloadInfo().download(url: url, destinationPath: nil)
            .downloadProgress({ (progress) in
                let completed: Float = Float(progress.completedUnitCount)
                let total: Float = Float(progress.totalUnitCount)
                let progressValue = completed/total
                progressBlock(progressValue)
            }).downloadResponse { (response) in
                print(response)
        }
    }
    
    
}
