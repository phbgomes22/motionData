//
//  Sample.swift
//  motionData
//
//  Created by Pedro Gomes on 25/09/18.
//  Copyright © 2018 Pedro Gomes. All rights reserved.
//

import UIKit

class Sample{
    
    let rotX, rotY, rotZ: Double
    let accX, accY, accZ: Double
    
    
    var description: String {
        let output =
            "RotX: \(rotX)   RotY: \(rotY)   RotZ: \(rotZ) \n" +
                "AccX: \(accX)   AccY: \(accY)   AccZ: \(accZ) \n" +
        "\n"
        
        return output
    }
    
    
    init(rotX: Double = 0.0, rotY: Double = 0.0, rotZ: Double = 0.0,
         accX: Double = 0.0, accY: Double = 0.0, accZ: Double = 0.0) {
        
        self.rotX = rotX; self.rotY = rotY; self.rotZ = rotZ
        self.accX = accX; self.accY = accY; self.accZ = accZ
    }
    
    
    func exportAsCommaSeparatedValues() -> String {
        let csv = "\(rotX),\(rotY),\(rotZ),\(accX),\(accY),\(accZ)\n"
        
        return csv
    }
    
}

