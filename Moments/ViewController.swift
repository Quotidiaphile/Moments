//
//  ViewController.swift
//  Moments_Proto
//
//  Created by David Newport on 11/6/18.
//  Copyright © 2018 Quotidiaphile. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var timer = QPTimer() // "Model" timer
    var formatter = DateComponentsFormatter() // For formatting the timer display label
    var uiTimer: Timer?   // Timer for updating the timer display label
    
    @IBOutlet weak var timerDisplayLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var logTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logTableView.dataSource = self
        logTableView.delegate = self
        
        // Set up the formatter for the timer display.
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.allowsFractionalUnits = true
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        // Tweak the timer label font to give us monospaced numbers.
        let timerFont = timerDisplayLabel.font
        
        let timerFontDescriptor = timerFont?.fontDescriptor
        
        let fontDescriptorFeatureSettings = [
            [
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
            ]
        ]
        
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
        if let monoFontDescriptor = timerFontDescriptor?.addingAttributes(fontDescriptorAttributes) {
            let newTimerFont = UIFont(descriptor: monoFontDescriptor, size: 0)
            timerDisplayLabel.font = newTimerFont
        }
        
        // Init the UI.
        updateTimerDisplay()
        updateStartStopButton()
    }
    
    func startUITimer() {
        uiTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (t) in
            self.updateTimerDisplay()
        })
        print("UI timer started.")
    }
    
    func stopUITimer() {
        uiTimer?.invalidate()
        uiTimer = nil
        print("UI timer stopped.")
    }
    
    // Starts the UI timer if the model timer is running.
    func activateUITimer() {
        if timer.isRunning {
            startUITimer()
        } else {
            stopUITimer()
        }
    }
    
    func updateTimerDisplay() {
        // TODO: Move this logic into the Timer class?
        if let elapsedTimeString = formatTimeInterval(timer.elapsedTime) {
            timerDisplayLabel.text? = elapsedTimeString
        }
    }
    
    // TODO: Should this be elsewhere?
    func formatTimeInterval(_ interval: TimeInterval) -> String? {
        return formatter.string(from: interval)
        /*
        if var intervalString = formatter.string(from: interval) {
            // Want .1s precision. DateComponentsFormatter only gives us 1s precision.
            let deciSeconds = (interval.truncatingRemainder(dividingBy: 1.0) * 10.0)
            // TODO: Use locale-specific decimal separator. Need further tweaking for localization?
            intervalString += ".\(Int(deciSeconds))"
            return intervalString
        }
        return nil
        */
    }
    
    func updateStartStopButton() {
        if timer.isRunning {
            startStopButton.setTitle("Stop", for: .normal)
        } else {
            startStopButton.setTitle("Start", for: .normal)
        }
    }
    
    func updateLogTable() {
        print("Updating log table: \(timer.logs)")
        logTableView.reloadData()
    }

    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        timer.toggle()
        updateTimerDisplay()
        updateStartStopButton()

        if timer.isRunning {
            startUITimer()
        } else {
            stopUITimer()
        }
    }
    
    @IBAction func logButtonPressed(_ sender: UIButton) {
        timer.log()
        updateLogTable()
        
        // Make sure the new log entry is visible.
        logTableView.scrollToRow(at: IndexPath(row: logTableView.numberOfRows(inSection: 0) - 1, section: 0), at: .none, animated: true)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        timer.reset()
        stopUITimer()
        updateTimerDisplay()
        updateStartStopButton()
        updateLogTable()
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerLogTableCell", for: indexPath)
        let logRecord = timer.logs[indexPath.row]

        cell.textLabel?.text = logRecord.label ?? ""
        cell.detailTextLabel?.text = formatTimeInterval(logRecord.elapsedTime)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timer.logs.count
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logRecord = timer.logs[indexPath.row]
        let label = logRecord.label ?? ""
        
        // TODO: Literals
        let alert = UIAlertController(title: "Timer Log", message: "Timer log label", preferredStyle: .alert)
        alert.addTextField{ $0.text = label }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let newLabel = alert.textFields?.first?.text {
                self.timer.logs[indexPath.row].label = newLabel
                print(self.timer.logs)
                self.updateLogTable()
            }
        } ))
        self.present(alert, animated: true, completion: nil)
    }
}
