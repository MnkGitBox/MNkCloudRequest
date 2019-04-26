//
//  UserDetailTableViewController.swift
//  MNkCloudRequest_Example
//
//  Created by MNk_Dev on 8/8/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MNkCloudRequest

class UserDetailTableViewController: UITableViewController {
    
    private var users:[User] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequest()
//        MNkCloudRequest.contentType = .json
//        fetchArrayData()
        tableView.tableFooterView = UIView()
    }
    
    private func fetchRequest(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MNkCloudRequest.request("https://jsonplaceholder.typicode.com/todos/1/users") { [weak self](users:[User]?, resdponse, err) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let _users = users,
                err == nil else{
                    print(err ?? "went wrong")
                    return
            }
           self?.users = _users
        }
    }
    
    private func fetchArrayData(){
        let param = [["id" : 2, "qty" : 2],
        ["id" : 3, "qty" : 10],
        ["id" : 4, "qty" : 2]]
        
        MNkCloudRequest.request("http://teamazbow.com/mojudev/mobile/getDeliveryCharge", .post, param) { (data, response, err) in
            print(Json(data).description)
        }
    }

}

//MARK:- IMPLEMENT UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension UserDetailTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subTitledCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].username
        return cell
    }
    
    
}
