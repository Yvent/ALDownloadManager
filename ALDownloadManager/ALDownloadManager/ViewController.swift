//
//  ViewController.swift
//  ALDownloadManager
//
//  Created by 周逸文 on 2017/11/8.
//  Copyright © 2017年 YV. All rights reserved.
//


///A progressive download manager for Alamofire.

import UIKit


let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {


    
    let downloadStyles: Array<Dictionary<String,UIViewController.Type>> = [["单文件下载":SingleFileDownloadVC.self],["多文件下载":MultipleFilesDownloadSTVC.self]]
    
    var alTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }

    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}

    func setupUI() {
        
        self.title = "ALDownloadManager"
        let tabFrame: CGRect = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        alTableView = UITableView(frame: tabFrame, style: .plain)
        alTableView.rowHeight = 60
        alTableView.delegate = self
        alTableView.dataSource = self
        alTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.view.addSubview(alTableView)
        
    }

}
extension ViewController: UITableViewDelegate ,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadStyles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell()
        }
        cell!.textLabel?.text = downloadStyles[indexPath.row].keys.first
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VCt = downloadStyles[indexPath.row].values.first
        let VC = VCt?.init()
          VC?.title = downloadStyles[indexPath.row].keys.first
        self.navigationController?.pushViewController(VC!, animated: true)
    }

}
