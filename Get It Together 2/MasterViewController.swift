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

    let myModel = Model()
    var eventStore: EKEventStore!
    var reminders: [EKReminder]!
    
    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted: Bool, error: NSError?) -> Void in
            
            if granted{
                // 2
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
        
        enterGenericTasksForTesting()
        
        objects = myModel.tasks as [Task]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
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
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! Task
        cell.textLabel!.text = object.description
        print(object.description)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func enterGenericTasksForTesting() {
        
        let newTask1:Task = Task()
        newTask1.title = "Do laundry"
        newTask1.note = "Here's a note"
        newTask1.userTags = ["tag1","tag2"]
        
        let newTask2:Task = Task()
        newTask2.title = "Take out the garbage"
        newTask2.note = "Here's a second note"
        newTask2.userTags = ["tag1","tag2"]
        
        let newTask3:Task = Task()
        newTask3.title = "Clean the kitchen"
        newTask3.note = "Here's a third note"
        newTask3.userTags = ["tag1","tag2"]
        
        
        myModel.tasks.append(newTask1)
        myModel.tasks.append(newTask2)
        myModel.tasks.append(newTask3)
        
        var count: Int = 0
        for task in myModel.tasks{
            
            let tempTask: Task = task
            
            NSLog("myModel Array Count: \(myModel.tasks.count)")
            NSLog("myModel Array Object: \(tempTask.description)")
            NSLog("Task Title: \(tempTask.title)")
            count += 1
        }
    }



}

