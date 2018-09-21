//
//  Helper.swift
//  TapDrive
//
//  Created by Sylwester Pilarz on 21.09.2018.
//  Copyright © 2018 Intengine. All rights reserved.
//

import Foundation
import UIKit

class Helper : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat, secondNumber : CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}
