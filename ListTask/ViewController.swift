//
//  ViewController.swift
//  ListTask
//
//  Created by Siva Kumar Reddy Thimmareddy on 11/09/19.
//  Copyright © 2019 Siva Kumar Reddy Thimmareddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    var numberOfListSelected:Int = 0
    var selectedIndexPaths:[Int] = []

    var hits: [Hit]?
    private var currentPage = 1
    private var shouldShowLoadingCell = false

    var refreshControl = UIRefreshControl()

    var isPaging : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        self.title = "Selected count = 0"


        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        getPostDataForPage(page: currentPage)
        // Do any additional setup after loading the view.
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.hits?.count ?? 0
        return shouldShowLoadingCell ? count + 1 : count

    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        var cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! UITableViewCell
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellReuseIdentifier)

        let switchView = UISwitch(frame: .zero)
        if switchView.isOn {
            switchView.setOn(true, animated: true)
        }
        else {
        switchView.setOn(false, animated: true)
        }
        switchView.tag = indexPath.row // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView

        let rowData = self.hits![indexPath.row]
        
        cell.textLabel?.text = rowData.title
        cell.detailTextLabel?.text = rowData.createdAt
    
        if indexPath.row == self.hits!.count-1 {
            fetchNextPage()
        }

        return cell
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let currentCell = tableView.cellForRow(at: indexPath)!
//
//
//        if selectedIndexPaths .contains(indexPath.row) {
//            let switchView = currentCell.viewWithTag(indexPath.row) as? UISwitch
//            switchView?.isOn = false
//            numberOfListSelected -= 1
//selectedIndexPaths.remo
//        }
//
//        if sender.isOn {
//            numberOfListSelected += 1
//        }
//        else {
//            numberOfListSelected -= 1
//        }
//        print(numberOfListSelected)
//        self.title = "Selected count = \(numberOfListSelected )"
//    }
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        if sender.isOn {
        numberOfListSelected += 1
        }
        else {
            numberOfListSelected -= 1
        }
        print(numberOfListSelected)
        self.title = "Selected count = \(numberOfListSelected )"
    }

    
    func getPostDataForPage(page : Int) {
        let urlPath = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(page)"
        let url = URL(string: urlPath)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
            print("Task completed")
            
            guard data != nil && error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    print(jsonResult)
                    let  postData = try? JSONDecoder().decode(PostData.self, from: data!)
                    if self.isPaging {
                        self.hits?.append(contentsOf: postData!.hits)
                    }
                    else {
                    self.hits = postData?.hits
                    }
                    DispatchQueue.main.async {
                        self.tableView.delegate = self
                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            } catch let parseError as NSError {
                print("JSON Error \(parseError.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    @objc
    private func refreshData() {
        currentPage = 1
        getPostDataForPage(page: currentPage)
        self.title = "Selected count = 0"

    }

    private func fetchNextPage() {
        currentPage += 1
        isPaging = true
        getPostDataForPage(page: currentPage)
    }

}

