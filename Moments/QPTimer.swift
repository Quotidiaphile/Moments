//
//  QPTimer.swift
//  Moments_Proto
//
//  Created by David Newport on 11/6/18.
//  Copyright © 2018 Quotidiaphile. All rights reserved.
//

import Foundation

struct QPTimerRecord {
    enum TimerAction {
        case start
        case stop
    }
    
    let action: TimerAction
    let timeStamp: Date
    let elapsedTime: TimeInterval
    var label: String? = nil
}

struct QPTimerLog {
    let timeStamp: Date
    let elapsedTime: TimeInterval
    var label: String?  = nil
}

struct QPTimer {
    var title = String()
    var notes = String()
    var records = [QPTimerRecord]()
    var logs = [QPTimerLog]()
    var lastKnownElapsedTime = TimeInterval()
    var lastStartTime = Date()
    var isRunning = false
    
    var elapsedTime: TimeInterval { return calcElapsedTime(currentTime: Date()) }
    
    func calcElapsedTime(currentTime: Date) -> TimeInterval {
        var elapsedTime = lastKnownElapsedTime
        if isRunning {
            elapsedTime += currentTime.timeIntervalSince(lastStartTime)
        }
        return elapsedTime
    }
    
    mutating func start() {
        let startTime = Date()
        guard !isRunning else { return }
        records.append(QPTimerRecord(action: .start, timeStamp: startTime, elapsedTime: lastKnownElapsedTime, label: nil))
        lastStartTime = startTime
        isRunning = true
    }
    
    mutating func stop() {
        let stopTime = Date()
        guard isRunning else { return }
        lastKnownElapsedTime = calcElapsedTime(currentTime: stopTime)
        records.append(QPTimerRecord(action: .stop, timeStamp: stopTime, elapsedTime: lastKnownElapsedTime, label: nil))
        isRunning = false
    }
    
    mutating func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    mutating func log(_ label: String? = nil) {
        let logTime = Date()
        let logLabel = label ?? "Log \(logs.count + 1)"
        logs.append(QPTimerLog(timeStamp: logTime, elapsedTime: calcElapsedTime(currentTime: logTime), label: logLabel))
        print("Logged at: \(logs.last!.elapsedTime)")
    }
    
    mutating func reset() {
        records.removeAll()
        logs.removeAll()
        lastKnownElapsedTime = TimeInterval()
        isRunning = false
    }
}
