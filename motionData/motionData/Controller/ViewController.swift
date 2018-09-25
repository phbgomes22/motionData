//
//  ViewController.swift
//  motionData
//
//  Created by Pedro Gomes on 25/09/18.
//  Copyright © 2018 Pedro Gomes. All rights reserved.
//

import UIKit
import CoreMotion
import MessageUI

class ViewController: UIViewController {

    
    @IBOutlet weak var recordButton: UIButton!
    
    
    lazy var motionManager = CMMotionManager()
    lazy var tremorSamples = [Sample]()
    var samplingStarted = false
    
    //
    //  INTERVAL MOTION
    //
    var intervalMotion = 1.0/50.0
    
    
    // MARK: - Base functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        stopMotionManager()
    }
    
    
    // MARK: - Motion manager
    
    
    func startMotionManager() {
        if motionManager.isAccelerometerAvailable {
            
            let queue = OperationQueue()
            
            //
            //      Speed of info
            //
            
            motionManager.deviceMotionUpdateInterval = intervalMotion
            
            motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
                if error != nil {
                    print(#function, error?.localizedDescription as Any)
                } else {
                    self.collectTremorSamples(motion: motion)
                }
            }
            
        } else {
            print("Accelerometer is not available.")
        }
    }
    
    
    func stopMotionManager() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
    @IBAction func startStopSampling(sender: AnyObject) {
        
        if !samplingStarted {
            startMotionManager()
            recordButton.setTitle("Stop", for: .normal)
            samplingStarted = true
            self.view.backgroundColor = UIColor.green
        } else {
            stopMotionManager()
            recordButton.setTitle("Record", for: .normal)
            samplingStarted = false
            showNotificationAfterRecording(titleText: "Question", messageText: "What do you want to do?")
            self.view.backgroundColor = UIColor.white
        }
        
    }
    
    
    // MARK: - Tremor samples
    
    
    func collectTremorSamples(motion: CMDeviceMotion!)  {
        
        let rotation: CMRotationRate = motion.rotationRate
        var rotX = rotation.x
        var rotY = rotation.y
        var rotZ = rotation.z
        
        let acceleration: CMAcceleration = motion.userAcceleration
        var accX = acceleration.x
        var accY = acceleration.y
        var accZ = acceleration.z
        
        if(rotX < 0.0001){
            rotX = 0
        };if(rotY < 0.0001){
            rotY = 0
        };if(rotZ < 0.0001){
            rotZ = 0
        };if(accX < 0.0001){
            accX = 0
        };if(accY < 0.0001){
            accY = 0
        };if(accZ < 0.0001){
            accZ = 0
        }
        
        let sample = Sample(rotX: rotX, rotY: rotY, rotZ: rotZ, accX: accX, accY: accY, accZ: accZ)
        
        tremorSamples.append(sample)
        
    }
    
    
    @IBAction func resetSamples(sender: AnyObject) {
        let alertController = UIAlertController(title: "Please confirm", message: "Are you sure you want to delete the samples?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (action) -> Void in
            self.tremorSamples = [Sample]()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Export data
    
    
    func csvFileWithPath() -> NSURL? {
        // Create date string from local timezone for filename
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        dateFormatter.dateFormat = "YYYY_MM_dd_hhmm"
        let localDateForFileName = dateFormatter.string(from: date as Date)
        
        // Create CSV file with output
        var csvString = "rotX,rotY,rotZ,accX,accY,accZ\n"
        for sample in tremorSamples {
            csvString += sample.exportAsCommaSeparatedValues()
        }
        let dirPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docsDir = dirPaths[0]
        let csvFileName = "TREMOR12_samples_\(localDateForFileName).csv"
        let csvFilePath = docsDir.appendingFormat("/" + csvFileName)
        
        // Generate output
        var csvURL: NSURL?
        do {
            try csvString.write(toFile: csvFilePath, atomically: true, encoding: String.Encoding.utf8)
            csvURL = NSURL(fileURLWithPath: csvFilePath)
        } catch {
            csvURL = nil
        }
        
        csvString = ""
        
        return csvURL
    }
    
    
    @IBAction func exportSamples(sender: AnyObject) {
        // Export content if possible, else show alert
        if let content = csvFileWithPath() {
            let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
            if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            }
            present(activityViewController, animated: true, completion: nil)
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "CSV file could not be created.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
        tremorSamples = [Sample]()
    }
    
    
    // MARK: - Notifications

    
    
    func showNotificationAfterRecording(titleText: String, messageText: String) {
        
        let controller = UIAlertController(title: titleText, message: messageText, preferredStyle: UIAlertController.Style.actionSheet)
        
        let exportAction = UIAlertAction(title: "Export data", style: .default) { (action) -> Void in
            self.exportSamples(sender: self)
        }
        controller.addAction(exportAction)
        
        let deleteAction = UIAlertAction(title: "Delete data", style: UIAlertAction.Style.destructive) { (action) -> Void in
            self.resetSamples(sender: self)
        }
        controller.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
        
    }


}

