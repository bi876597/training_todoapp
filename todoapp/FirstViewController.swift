//
//  FirstViewController.swift
//  todoapp
//
//  Created by user on 2017/10/26.
//  Copyright © 2017年 mactraining. All rights reserved.
//

import UIKit
import CDTDatastore

class FirstViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var myTableView: UITableView!
//  var datastore : CDTDatastore
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // ローカルのCloudantからデータ取得。結果の要素数をセル（table）の数として設定
    let result = datastore.getAllDocuments()
    return (result.count)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // セルの定義を設定し、ローカルのcloudantに格納されたタスク名とエンド時間を表示するセル（table）を作成
    let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
    var result = datastore.getAllDocuments()
    cell.textLabel?.text = result[indexPath.row].body["task"] as? String
    cell.detailTextLabel?.text = result[indexPath.row].body["end_time"] as? String
    return(cell)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    // Deleteボタンを押下された時に以下を実施
    if editingStyle == UITableViewCellEditingStyle.delete {
      let result = datastore.getAllDocuments()
      let delete_task = result[indexPath.row].docId!
      try! datastore.deleteDocument(withId: delete_task)
      
    // replication to bluemix
      datastore.push(to: remote) {error in
        if error != nil {
            print("レプリケーション失敗(delete item): ¥(error)")
          } else {
            print("レプリケーション成功(delete item)")
          }
      }
    }
    myTableView.reloadData()
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
