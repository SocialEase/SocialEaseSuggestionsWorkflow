//
//  ViewController.swift
//  SocialEaseSuggestionsWorkflow
//
//  Created by Amay Singhal on 10/17/15.
//  Copyright © 2015 ple. All rights reserved.
//

import UIKit
import Parse
import JTProgressHUD

enum SuggestionsViewTableType {
    case SuggestionsTable, FilterTable
}


class SuggestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityTypeView: UIView!
    @IBOutlet weak var timeInformationView: UIView!
    @IBOutlet weak var activityTypeTextLabel: UILabel!
    @IBOutlet weak var activityTypeArrowIndicator: UILabel!
    @IBOutlet weak var dateTimeTextLabel: UILabel!
    @IBOutlet weak var dateTimeArrowIndicator: UILabel!
    @IBOutlet weak var filterOptionsTableView: UITableView!
    @IBOutlet weak var suggestedPlaceTableView: UITableView!

    @IBOutlet weak var sendButtonFooterView: UIView!
    @IBOutlet weak var sendButton: UILabel!

    var groupId: Int!

    var showActivityTypeFilter = false {
        didSet {
            filterOptionsTableView.reloadData()
            UIView.animateWithDuration(0.5) { () -> Void in
                self.filterOptionsTableView.alpha = self.showActivityTypeFilter ? 1 : 0
                self.updateFilterDisplay(self.activityTypeTextLabel, arrowLabel: self.activityTypeArrowIndicator, filterState: self.showActivityTypeFilter)
                self.view.layoutIfNeeded()
            }
        }
    }

    var showTimeDateFilter = false {
        didSet {
            
            filterOptionsTableView.reloadData()
            UIView.animateWithDuration(0.5) { () -> Void in
                self.filterOptionsTableView.alpha = self.showTimeDateFilter ? 1 : 0
                self.updateFilterDisplay(self.dateTimeTextLabel, arrowLabel: self.dateTimeArrowIndicator, filterState: self.showTimeDateFilter)
                self.view.layoutIfNeeded()
            }
        }
    }

    var dateFilterList = [SuggestionsFilter]()
    var activityTypeFilterList = [SuggestionsFilter]()
    var suggestedActivities: [(activity: SEAActivity, selected: Bool)]? {
        didSet {
            suggestedPlaceTableView?.reloadData()
            updateSendButtonActiveState()
        }
    }

    var filterTableViewData: [SuggestionsFilter] {
        if showActivityTypeFilter {
            return activityTypeFilterList
        } else if showTimeDateFilter {
            return dateFilterList
        } else {
            return [SuggestionsFilter]()
        }
    }

    var filterTextLabel: UILabel {
        if showActivityTypeFilter {
            return activityTypeTextLabel
        } else if showTimeDateFilter {
            return dateTimeTextLabel
        } else {
            return UILabel()
        }
    }

    var selectedAcitivitiesCount: Int? {
        return suggestedActivities?.filter( { $0.selected } ).count
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // hard coded for now
        groupId = 12345

        // Do any additional setup after loading the view, typically from a nib.
        suggestedPlaceTableView.delegate = self
        suggestedPlaceTableView.dataSource = self
        suggestedPlaceTableView.rowHeight = UITableViewAutomaticDimension
        suggestedPlaceTableView.estimatedRowHeight = 180
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: suggestedPlaceTableView.bounds.width, height: 30))
        footerView.backgroundColor = UIColor.clearColor()
        suggestedPlaceTableView.tableFooterView = footerView

        filterOptionsTableView.delegate = self
        filterOptionsTableView.dataSource = self
        filterOptionsTableView.rowHeight = UITableViewAutomaticDimension
        filterOptionsTableView.estimatedRowHeight = 51

        activityTypeView.addBorderToViewAtPosition(.Bottom)
        timeInformationView.addBorderToViewAtPosition(.Bottom)
        timeInformationView.addBorderToViewAtPosition(.Left)

        initDateFilter()
        initActivityTypeFilter()

        fetchSuggestions()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestedPlaceTableView {
            return suggestedActivities?.count ?? 0
        } else {
            return filterTableViewData.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == suggestedPlaceTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("SuggestedPlaceViewCell", forIndexPath: indexPath) as! SuggestedPlaceViewCell
            cell.activity = suggestedActivities?[indexPath.row].activity
            cell.cellSelected = suggestedActivities?[indexPath.row].selected
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FilterOptionViewCell", forIndexPath: indexPath) as! FilterOptionViewCell
            cell.filter = filterTableViewData[indexPath.row]
            return cell
        }
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == filterOptionsTableView {
            for i in 0 ..< filterTableViewData.count {
                filterTableViewData[i].isSelected = false
            }
            filterTableViewData[indexPath.row].isSelected = true
            filterTextLabel.text = filterTableViewData[indexPath.row].displayName

            showActivityTypeFilter ? activityTypeViewTapped(nil) : timeViewTapped(nil)
        } else {
            suggestedActivities?[indexPath.row].selected = !(suggestedActivities?[indexPath.row].selected)!
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }

    }

    @IBAction func timeViewTapped(sender: UITapGestureRecognizer?) {
        showActivityTypeFilter = false
        showTimeDateFilter = !showTimeDateFilter
        !showActivityTypeFilter && !showTimeDateFilter ? fetchSuggestions() : ()
    }

    @IBAction func activityTypeViewTapped(sender: UITapGestureRecognizer?) {
        showTimeDateFilter = false
        showActivityTypeFilter = !showActivityTypeFilter
        !showActivityTypeFilter && !showTimeDateFilter ? fetchSuggestions() : ()
    }

    @IBAction func sendBottonTapped(sender: UITapGestureRecognizer) {
        if selectedAcitivitiesCount == 0 {
            sendButton.text = "Nothing selected!"
            sendButton.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.7)
            UIView.animateWithDuration(2.0, animations: { () -> Void in
                self.sendButton.alpha = 0
                }) { (success: Bool) -> Void in
                    self.sendButton.text = "SEND"
                    self.sendButton.textColor = UIColor.darkGrayColor()
                    self.sendButton.alpha = 1
            }
        } else {
            
        }
    }
    

    private func updateFilterDisplay(filterTextLabel: UILabel, arrowLabel: UILabel, filterState: Bool) {
        if filterState {
            filterTextLabel.textColor = UIColor(red: 255/255, green: 153/255, blue: 90/255, alpha: 1)
            arrowLabel.textColor = UIColor(red: 255/255, green: 153/255, blue: 90/255, alpha: 1)
            arrowLabel.transform = CGAffineTransformMakeRotation(CGFloat(2 * M_PI_2))
        } else {
            filterTextLabel.textColor = UIColor.darkGrayColor()
            arrowLabel.textColor = UIColor.darkGrayColor()
            arrowLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
        }
    }

    private func initDateFilter() {
    
        let dates = DateUtils.getNextNDatesWithCount(7, fromStartDate: NSDate())
        dateFilterList.append(DisplayDateFilter(date: dates[0], isSelected: true))
        for i in 1 ..< dates.count {
            dateFilterList.append(DisplayDateFilter(date: dates[i], isSelected: false))
        }
    }

    private func initActivityTypeFilter() {
        activityTypeFilterList.append(DisplayActivityTypeFilter(name: "Lunch", isSelected: true))
        activityTypeFilterList.append(DisplayActivityTypeFilter(name: "Dinner", isSelected: false))
        activityTypeFilterList.append(DisplayActivityTypeFilter(name: "Coffee", isSelected: false))
        activityTypeFilterList.append(DisplayActivityTypeFilter(name: "Happy Hour", isSelected: false))
        activityTypeFilterList.append(DisplayActivityTypeFilter(name: "Hiking", isSelected: false))
    }

    private func fetchSuggestions() {
        JTProgressHUD.showWithStyle(JTProgressHUDStyle.Gradient)
        SEAActivity.getSuggestedActivitiesForGroupId(groupId) { (suggestedActivities: [SEAActivity]?, error: NSError?) -> () in
            JTProgressHUD.hide()
            if let suggestedActivities = suggestedActivities {
                self.suggestedActivities = suggestedActivities.map { ($0, false) }
            }
        }
    }

    private func updateSendButtonActiveState() {
        if selectedAcitivitiesCount > 0 {
            sendButton.textColor = UIColor(red: 255/255, green: 204/255, blue: 102/255, alpha: 1)
            sendButtonFooterView.backgroundColor = UIColor(red: 0/255, green: 114/255, blue: 187/255, alpha: 0.95)
        } else {
            sendButton.textColor = UIColor.darkGrayColor()
            sendButtonFooterView.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 0.95)
        }
    }
}

