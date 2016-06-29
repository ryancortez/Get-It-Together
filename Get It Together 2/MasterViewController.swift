//
//  MasterViewController.swift
//  Get It Together 2
//
//  Created by Ryan Cortez on 5/29/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import EventKit

class MasterViewController: UITableViewController {

    var eventStore: EKEventStore!
    var reminders: [EKReminder]!
    
    var detailViewController: DetailViewController? = nil

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showTutorialOnFirstLaunch()
        setupNavigationBar()
        implementSplitScreen()
        getRemindersFromSystem()
        
        }
    
// MARK: - Inital Launch
    
    func showTutorialOnFirstLaunch() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !userDefaults.boolForKey("walkthroughPresented") {
            showTutorial()
            userDefaults.setBool(true, forKey: "walkthroughPresented")
            userDefaults.synchronize()
        }
    }
    
// MARK: - Reminders
    
    func getRemindersFromSystem() {
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted: Bool, error: NSError?) -> Void in
            
            if granted{
                let predicate = self.eventStore.predicateForRemindersInCalendars(nil)
                self.eventStore.fetchRemindersMatchingPredicate(predicate, completion: { (reminders: [EKReminder]?) -> Void in
                    
                    self.reminders = reminders
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }else{
                print("The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }
        }
    }
    
// MARK: - Helper Methods
    
    func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func insertNewObject(sender: AnyObject) {
        reminders.insert(EKReminder(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func implementSplitScreen () {
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    }

    func showTutorial() {
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let tutorialViewController = storyboard.instantiateViewControllerWithIdentifier("tutorialViewController") as! TutorialViewController
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }

   
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = reminders[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("reminderCell")
        let reminder:EKReminder! = self.reminders![indexPath.row]
        cell.textLabel?.text = reminder.title
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        if let dueDate = reminder.dueDateComponents?.date{
            cell.detailTextLabel?.text = formatter.stringFromDate(dueDate)
        }else{
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let reminder: EKReminder = reminders[indexPath.row]
        do{
            try eventStore.removeReminder(reminder, commit: true)
            self.reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }catch{
            print("An error occurred while removing the reminder from the Calendar database: \(error)")
        }
        
        if editingStyle == .Delete {

        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}

