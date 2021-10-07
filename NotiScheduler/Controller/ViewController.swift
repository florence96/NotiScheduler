//
//  ViewController.swift
//  NotiScheduler
//
//  Created by Yejin Hong on 2021/09/09.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditScheduleVCDelegate {
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var onOffSwitch: UIButton!
    
    //    public var onOffButtonStatus: Bool = true
    public var mainOnOffStatus: String = "y"
    public var eachScheduleOnOffStatus: Bool = true
    public var totalScheduleCount: Int = 0
    public var storedScheduleData: [ScheduleData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        //for removing unnecessary tableview lines
        scheduleTableView.tableFooterView = UIView()
        //to customize tableview's height
        scheduleTableView.rowHeight = UITableView.automaticDimension
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
    }
    
    //to maintain the title
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Schedule"
        let addScheduleVC: AddScheduleVC = storyboard?.instantiateViewController(identifier: "AddScheduleVC") as! AddScheduleVC
        addScheduleVC.editScheduleVCDelegate = self
        scheduleTableView.reloadData()
    }
    
    func loadUpdatedDataToViewController(data: ScheduleData) {
        self.storedScheduleData.append(data)
        totalScheduleCount += 1
    }
    func editDataFromViewController(indexPath: IndexPath, data: ScheduleData) {
        self.storedScheduleData[indexPath.row] = data
    }
    func deleteDataFromViewController(indexPath: IndexPath) {
        totalScheduleCount -= 1
        self.storedScheduleData.remove(at: indexPath.row)
        scheduleTableView.deleteRows(at: [indexPath], with: .none)
    }
    
    @IBAction func showAddSchedule(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "AddScheduleVC") as? AddScheduleVC {
            vc.checkIfAddOrEdit = 1
            vc.editScheduleVCDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func sendDataToServer(_ sender: Any) {
        var sendJsonData = ["use_all": mainOnOffStatus, "schedules": []] as [String : Any]
        var dataArray: [Any] = []
        
        if totalScheduleCount == 0 { return }
        
        for i in 0...totalScheduleCount-1 {
            let name = self.storedScheduleData[i].name
            let use = self.storedScheduleData[i].onOff ? "y" : "n"
            let day = self.storedScheduleData[i].day.joined(separator: ",")
            let start = self.storedScheduleData[i].startTime
            let end = self.storedScheduleData[i].endTime
            
            let param = ["name":name, "use": use, "day": day, "start": start, "end": end] as [String : Any]
            if let theJSONData = try? JSONSerialization.data(withJSONObject: param, options: []) {
                let theJSONText = String(data: theJSONData, encoding: .utf8)
                dataArray.append(theJSONText!)
            }
            sendJsonData.updateValue(dataArray, forKey: "schedules")
            
            if let jsonResult = try? JSONSerialization.data(withJSONObject: sendJsonData, options: []) {
                let theJSONText = String(data: jsonResult, encoding: .utf8)
                
                print("theJSONText = \(theJSONText!)")
            }
        }
    }
    
    @IBAction func onOffSwitch(_ sender: Any) {
        if eachScheduleOnOffStatus == true {
            self.mainOnOffStatus = "n"
            onOffSwitch.setImage(UIImage(named: "switch_off"), for: .normal)
            eachScheduleOnOffStatus = false
        } else {
            self.mainOnOffStatus = "y"
            onOffSwitch.setImage(UIImage(named: "switch_on"), for: .normal)
            eachScheduleOnOffStatus = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return totalScheduleCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
            cell.scheduleName.text = storedScheduleData[indexPath.row].name
            cell.time.text = "\(storedScheduleData[indexPath.row].startTime) ~ \(storedScheduleData[indexPath.row].endTime)"
            cell.day.text = storedScheduleData[indexPath.row].day.joined(separator: ", ")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //cell 눌럿을 때 회색박스 안생기게
        tableView.deselectRow(at: indexPath, animated: true)
        if let addScheduleVC = storyboard?.instantiateViewController(identifier: "AddScheduleVC") as? AddScheduleVC {
            addScheduleVC.checkIfAddOrEdit = 0
            addScheduleVC.name = storedScheduleData[indexPath.row].name
            addScheduleVC.onOffSwitch = storedScheduleData[indexPath.row].onOff
            
            addScheduleVC.dayArray = storedScheduleData[indexPath.row].day
            addScheduleVC.startTime = storedScheduleData[indexPath.row].startTime
            addScheduleVC.endTime = storedScheduleData[indexPath.row].endTime
            addScheduleVC.indexPath = indexPath
            addScheduleVC.editScheduleVCDelegate = self;

            navigationController?.pushViewController(addScheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
//    왼쪽으로 밀어서 행 삭제
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
//    {
//        let DeleteAction = UIContextualAction(style: .destructive, title:  "삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            self.totalScheduleCount -= 1
//                       self.storedScheduleData.remove(at: indexPath.row)
//                       tableView.deleteRows(at: [indexPath], with: .fade)
//            print("Delete")
//            success(true)
//        })
//        DeleteAction.backgroundColor = .red
//
//        let OffAction = UIContextualAction(style: .normal, title:  "끄기", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            print("On/Off")
//            success(true)
//        })
//        OffAction.backgroundColor = .gray
//        return UISwipeActionsConfiguration(actions: [DeleteAction,OffAction])
//    }
}
