//
//  MultipleFilesDownloadSTVC.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/8.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class MultipleFilesDownloadSTVC: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    
    
    
    let testUrl: String = "http://song.paohaile.com/30854966.mp3"
    
    var downloadurls = ["http://120.25.226.186:32812/resources/videos/minion_01.mp4",
                        "http://120.25.226.186:32812/resources/videos/minion_02.mp4",
                        "http://120.25.226.186:32812/resources/videos/minion_03.mp4",
                        "http://120.25.226.186:32812/resources/videos/minion_04.mp4",
                        "http://120.25.226.186:32812/resources/videos/minion_05.mp4",
                        "http://120.25.226.186:32812/resources/videos/minion_06.mp4"]
    let alTableView: UITableView = {
        let tabv = UITableView(frame: CGRect.zero, style: .plain)
        tabv.rowHeight = 80
        return tabv
    }()
    
    let alToolView: UIView = {
        let tView = UIView()
        tView.backgroundColor = UIColor(red: 245/255, green:  245/255, blue:  245/255, alpha: 1)
        return tView
    }()
    //暂停或恢复所有
    let suspendAllBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("全部下载", for: .normal)
        btn.setTitle("全部暂停", for: .selected)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn
    }()
    //顺序下载
    let sequentialAllBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("顺序下载", for: .normal)
        btn.setTitle("同时下载", for:  .selected)
        btn.setTitleColor(UIColor.black, for: .normal)
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
        self.view.backgroundColor = UIColor.white
        addNavRightItem()
        alTableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-60)
        alTableView.delegate = self
        alTableView.dataSource = self
        alTableView.register(DownloadProgressCell.self, forCellReuseIdentifier: "DownloadProgressCell")
        self.view.addSubview(alTableView)
        createToolView()
    }
    func addNavRightItem() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(navRightItemClicked), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    func createToolView() {
        alToolView.frame = CGRect(x: 0, y: ScreenHeight-60, width: ScreenWidth, height: 60)
        suspendAllBtn.frame = CGRect(x: 0, y: 0, width: ScreenWidth/2, height: 60)
        sequentialAllBtn.frame = CGRect(x: ScreenWidth/2, y: 0, width: ScreenWidth/2, height: 60)
        suspendAllBtn.addTarget(self, action: #selector(MultipleFilesDownloadSTVC.didsuspendAllBtn), for: .touchUpInside)
        sequentialAllBtn.addTarget(self, action: #selector(MultipleFilesDownloadSTVC.didsequentialAllBtn), for: .touchUpInside)
        self.view.addSubview(alToolView)
        alToolView.addSubview(suspendAllBtn)
        alToolView.addSubview(sequentialAllBtn)
    }
    @objc func navRightItemClicked()  {
        inputUrl()
    }
    
    //暂停或恢复所有
    func didsuspendAllBtn() {
        if self.suspendAllBtn.isSelected == true {
            self.suspendAllBtn.isSelected = false
            ALDownloadManager.shared.suspendAll()
        }else{
            self.suspendAllBtn.isSelected = true
            ALDownloadManager.shared.resumeAll()
        }
    }
    //顺序下载
    func didsequentialAllBtn() {
        if sequentialAllBtn.isSelected == true {
            sequentialAllBtn.isSelected = false
            ALDownloadManager.shared.changeDownloadState()
        }else{
            sequentialAllBtn.isSelected = true
            ALDownloadManager.shared.changeWaitState(completeClose: nil)
        }
    }
    
    func inputUrl() {
        let alertVC = UIAlertController(title: "新建下载任务", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertVC.addTextField { (tf) in
            tf.placeholder = "\(self.testUrl)"
        }
        let acSure = UIAlertAction(title: "下载", style: .default) { (sureact) in
            if  let downloadUrl = alertVC.textFields?.first?.text , downloadUrl != ""{
                if  let info =   ALDownloadManager.shared.download(url: downloadUrl), let url = info.downloadurl{
                    self.downloadurls.append(url)
                    self.alTableView.reloadData()
                }else{
                    self.alTip()
                }
            }else{
                if let request =   ALDownloadManager.shared.download(url: self.testUrl) {
                    print("\(request)")
                    self.downloadurls.append(self.testUrl)
                    self.alTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadurls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Identifier = "DownloadProgressCell\(indexPath.row)"
        if  let cell  = tableView.dequeueReusableCell(withIdentifier: Identifier) as? DownloadProgressCell {
            cell.downloadurl = downloadurls[indexPath.row]
            return   cell
        }else{
            tableView.register(DownloadProgressCell.self, forCellReuseIdentifier: Identifier)
            let cell  = tableView.dequeueReusableCell(withIdentifier: Identifier) as! DownloadProgressCell
            cell.downloadurl = downloadurls[indexPath.row]
            return   cell
        }
    }
}
