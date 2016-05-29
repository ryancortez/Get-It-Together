//
//  Task.swift
//  Get It Together
//
//  Created by Ryan on 1/30/15.
//  Copyright (c) 2015 Full Screen Ahead. All rights reserved.
//

import Foundation


class Task {
var title:NSString = NSString()
var userTags:NSMutableArray = NSMutableArray()
var note:NSString = NSString()

    var description: String {
        return "\(title)"
    }
}



