//
//  ViewController.swift
//  DiceRoller
//
//  Created by Pedro Gomes on 26/09/18.
//  Copyright © 2018 Pedro Gomes. All rights reserved.
//

import UIKit
import CoreML
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var theDice: UIImageView!
    
    @IBOutlet weak var rollDiceLabel: UILabel!
    
    // model
    let rollDiceModel = RollDiceModel()
    
    // for ML => [0,50] => tamanho da janela para comparar com o modelo
    var currentIndexInPredictionWindow = 0
    
    // motion manager for sensors
    let motionManager = CMMotionManager()
    
    
    let predictionWindowDataArray = try? MLMultiArray(
        shape: [1, ModelConstants.predictionWindowSize, ModelConstants.numOfFeatures] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    var lastHiddenOutput = try? MLMultiArray(
        shape: [ModelConstants.hiddenInLength as NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    var lastHiddenCellOutput = try? MLMultiArray(
        shape: [ModelConstants.hiddenCellInLength as NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        DispatchQueue.global().async {
            
            self.startMotionSensor()
            
            while(true){
                self.getSensorSamples()
                usleep(useconds_t(ModelConstants.sensorsUpdateInterval*1000000))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.stopMotionSensor()
    }

    
    // MARK: - Getting the data
    
    func stopMotionSensor(){
        motionManager.stopGyroUpdates()
        motionManager.stopAccelerometerUpdates()
        
    }
    
    func startMotionSensor() {
        
        motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
        motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
        
        // Accelerometer sensor
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        
    }
    
    
    
    func performModelPrediction () -> String?{
        guard let dataArray = predictionWindowDataArray else { return "Error!"}
        
        // perform model prediction
        
        let modelPrediction = try? rollDiceModel.prediction(features: dataArray, hiddenIn: lastHiddenOutput, cellIn: lastHiddenCellOutput)
        
        // update the state vectors
        lastHiddenOutput = modelPrediction?.hiddenOut
        lastHiddenCellOutput = modelPrediction?.cellOut
        
        print(modelPrediction?.activityProbability)
        
        // return the predicted activity -- the activity with the highest probability
        return modelPrediction?.activity
    }
    
    @discardableResult
    func getSensorSamples() -> Bool {
        guard let dataArray = predictionWindowDataArray  else {
            return false
        }
        
        guard let accelerometerSample = motionManager.accelerometerData else {return false}
        
        guard let gyroSample = motionManager.gyroData else {return false}
        
        var accX = accelerometerSample.acceleration.x
        if(accX < 0.0001){
            accX = 0.0
        }
        var accY = accelerometerSample.acceleration.y
        if(accY < 0.0001){
            accY = 0.0
        }
        var accZ = accelerometerSample.acceleration.z
        if(accZ < 0.0001){
            accZ = 0.0
        }
        
        var gyroX = gyroSample.rotationRate.x
        if(gyroX < 0.0001){
            gyroX = 0.0
        }
        var gyroY = gyroSample.rotationRate.y
        if(gyroY < 0.0001){
            gyroY = 0.0
        }
        var gyroZ = gyroSample.rotationRate.z
        if(gyroZ < 0.0001){
            gyroZ = 0.0
        }
        
        
        dataArray[[0, currentIndexInPredictionWindow, 0] as [NSNumber]] = accX as NSNumber
        dataArray[[0, currentIndexInPredictionWindow, 1] as [NSNumber]] = accY as NSNumber
        dataArray[[0, currentIndexInPredictionWindow, 2] as
            [NSNumber]] = accZ as NSNumber
        dataArray[[0, currentIndexInPredictionWindow, 3] as [NSNumber]] = gyroX as NSNumber
        dataArray[[0, currentIndexInPredictionWindow, 4] as [NSNumber]] = gyroY as NSNumber
        dataArray[[0, currentIndexInPredictionWindow, 5] as [NSNumber]] = gyroZ as NSNumber
        
        // update the index in the prediction window data array
        currentIndexInPredictionWindow += 1
        
        // If the data array is full, call the prediction method to get a new model prediction.
        // We assume here for simplicity that the Gyro data was added to the data array as well.
        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            
            // predict activity
            let predictedActivity = performModelPrediction() ?? "N/A"
            
            // user the predicted activity here
            print(predictedActivity)
            
            if(predictedActivity ==  "roll_dice"){
                
                self.rollTheDice()
                
            }
            // start a new prediction window
            currentIndexInPredictionWindow = 0
            return true
        }
        
        
        return false
    }
    
    func rollTheDice() {
        
        DispatchQueue.main.sync {
            rollDiceLabel.text = "Rolling..."
        }
        
        var i = 0
        
        while(i < 20){
            let num = arc4random_uniform(6) + 1
            
            let image = UIImage(named: "dice-\(num)")
            
            DispatchQueue.main.sync {
               self.theDice.image = image!
            }
            
        
            i += 1
            usleep(125000)
        }
        DispatchQueue.main.sync {
        
            
            rollDiceLabel.text = "Roll the dice!"
        }
    }
    
}

