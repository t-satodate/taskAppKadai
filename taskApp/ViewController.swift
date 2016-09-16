//
//  ViewController.swift
//  taskApp
//
//  Created by 里舘 徹 on 2016/09/07.
//  Copyright © 2016年 tooru.satodate. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DBないのタスクが格納されるリスト
    //　日付近い順＼順でソート：降順
    //　以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
  
    
    // MARK: - Life Cycle
    
    // 入力画面から戻ってきた時に　TableViewを更新させる
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupSearchBar()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - サーチバー設置
    func setupSearchBar(){
        
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "Search"
            searchBar.showsCancelButton = true
            searchBar.autocapitalizationType = UITextAutocapitalizationType.None
            searchBar.keyboardType = UIKeyboardType.Default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        
        searchBar.resignFirstResponder()
    }

    // 検索ボタン押下時の呼び出し
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let search = searchBar.text
        print(taskArray)
        
        taskArray = try! Realm().objects(Task).filter("category BEGINSWITH[c] %@", search!)
      
        searchBar.becomeFirstResponder()
            
        searchBar.endEditing(true)
        
        tableView.reloadData()
    }
    
    
    
    // MARK: - UITableViewDataSourceプロトコルのメソッド
    // データーの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return taskArray.count
    }
    
    //　各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
     

        // 再利用可能な　cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // CEllに値を設定する
        let task = taskArray[indexPath.row]
        
        cell.textLabel?.text = task.title
  
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
               return cell
        
     
    }

    // MARK: UITableViewDelegate
    //　各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("cellSegue",sender: nil) // ←追加する
    }

    
    //　セルが削除が可能なことを伝えるメソッド
    func tableView(tablewView: UITableView, editingStyleorRowAtIndexPath: NSIndexPath) -> UITableViewCellEditingStyle{
        
        return UITableViewCellEditingStyle.Delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath ){
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // データーベースから削除する
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
            
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break
              }
   
            }
        
        // データーベースから削除
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indxPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indxPath!.row]
            
        } else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
               task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }

}

