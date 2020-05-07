//
//  MultipleFilesDownloadSTVC.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/8.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class MultipleFilesDownloadSTVC: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    
    var downloadInfos = [ALDownloadInfo(url: "https://central.github.com/deployments/desktop/desktop/latest/darwin"),
                         ALDownloadInfo(url: "https://central.github.com/deployments/desktop/desktop/latest/darwin")]
    
    
    let alTableView: UITableView = {
        let tabv = UITableView(frame: CGRect.zero, style: .plain)
        tabv.rowHeight = 80
        
        return tabv
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
        alTableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-60)
        alTableView.delegate = self
        alTableView.dataSource = self
        alTableView.register(DownloadProgressCell.self, forCellReuseIdentifier: String(describing: DownloadProgressCell.self))
        view.addSubview(alTableView)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DownloadProgressCell.self), for: indexPath) as! DownloadProgressCell
        cell.model = downloadInfos[indexPath.row]
        return cell
    }
}
