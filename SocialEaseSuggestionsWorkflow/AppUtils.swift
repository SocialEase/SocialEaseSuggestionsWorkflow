//
//  AppUtils.swift
//  SocialEaseSuggestionsWorkflow
//
//  Created by Amay Singhal on 10/18/15.
//  Copyright © 2015 ple. All rights reserved.
//

import Foundation

protocol SuggestionsFilter: class {

    var displayName: String { get }
    var isSelected: Bool { get set }
}

class DisplayDateFilter: SuggestionsFilter {


    var date: NSDate
    var selected: Bool

    var displayName: String {
        return DateUtils.getDisplayDate(date)
    }

    var isSelected: Bool {
        get {
            return selected
        }
        set(newValue) {
            selected = newValue
        }
    }

    init(date: NSDate, isSelected selected: Bool) {
        self.date = date
        self.selected = selected
    }
}



class DisplayActivityTypeFilter: SuggestionsFilter {

    var activityName: String
    var selected: Bool

    var displayName: String {
        return activityName
    }

    var isSelected: Bool {
        get {
            return selected
        }
        set(newValue) {
            selected = newValue
        }
    }

    init(name: String, isSelected selected: Bool) {
        activityName = name
        self.selected = selected
    }
}