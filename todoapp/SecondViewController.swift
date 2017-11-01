//
//  SecondViewController.swift
//  todoapp
//
//  Created by user on 2017/10/26.
//  Copyright © 2017年 mactraining. All rights reserved.
//

import UIKit
import CDTDatastore

// cloudant(CDTDatastore)を利用するために必要な設定
let fileManager = FileManager.default
let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
let storeURL = documentsDir.appendingPathComponent("cloudant-sync-datastore")
let path = storeURL.path
let manager = try! CDTDatastoreManager(directory: path)
let datastore = try! manager.datastoreNamed("my_datastore")
let remote = URL(string: "https://cde4f05d-dd91-4b28-9f7e-c09406828bb7-bluemix:aebb3f582d878431e8fa006987846abaa319f720999389989f8ef929c31b079a@cde4f05d-dd91-4b28-9f7e-c09406828bb7-bluemix.cloudant.com/todoapp")!

class SecondViewController: UIViewController {
  // 日付入力用の変数を宣言
  var input_time:String = ""
  // 日付スタイルを設定するためのクラス呼び出し
  let formatter = DateFormatter()
  
  @IBOutlet weak var input: UITextField!
  @IBAction func addDate(_ sender: UIDatePicker) {
  // 入力時間を以下の日付スタイルで変数(String)に格納
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    input_time = formatter.string(from: sender.date)
  }
  
  @IBAction func addItem(_ sender: Any) {
  
    if ( input.text != "" && input_time != ""){
      // 現在日時を取得し変数(String)に格納
      let date = Date()
      formatter.dateFormat = "yyyy/MM/dd HH:mm" // 日付スタイルを修正
      let string_time = formatter.string(from: date)
      // ローカルのcloudantにデータを格納するため必要な_idに上記で取得した現在日付を指定する
      let rev = CDTDocumentRevision(docId: string_time)
      // 格納するタスク情報をJSON形式で生成
      rev.body = [
        "task" : input.text!,
        "end_time" : input_time
      ]
      // ローカルのcloudantにタスク情報を格納
      try! datastore.createDocument(from: rev)
      
      // ローカルのcloudantに格納されたデータをBluemix上のcloudantにレプリケーション
      datastore.push(to: remote) {error in
        if error != nil {
          print("レプリケーション失敗(add item): ¥(error)")
        } else {
          print("レプリケーション成功(add item)")
        }
      }
      // 入力タスクをクリア
      input.text = ""
    }
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

