import UIKit
import CoreMotion

class AccelerometerStepCounter {
    private let frameRate = 50
    private var accelerating = false
    private let shortBuffer = RingBuffer(capacity: 4)
    private let longBuffer = RingBuffer(capacity: 35)
    private let quantisationStep = 0.25
    private let accelerometer = CMMotionManager()
    private let stepQueue = NSOperationQueue()
    
    var stepTarget:Int?
    var onStepTargetReached:() -> () = {}
    var onStep:() -> () = {}
    var onAccelerationMeasured:(Double,Double,Double,Double) -> () = { value in }
    
    var steps = 0 {
        didSet {
            guard steps > 0 else { return }
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.onStep()
            }
    
            if stepTarget != nil && steps >= stepTarget {
                stepTarget = nil
                dispatch_sync(dispatch_get_main_queue()) {
                    self.onStepTargetReached()
                }
            }
        }
    }
    
    init() {
        stepQueue.maxConcurrentOperationCount = 1
    }
    
    func start() {
        reset()
        accelerometer.accelerometerUpdateInterval = 1.0 / Double(frameRate)
        accelerometer.startAccelerometerUpdatesToQueue(stepQueue) { data, error in
            guard let data = data else { return }
            let acceleration:CMAcceleration = data.acceleration
            
            let x = acceleration.x
            let y = acceleration.y
            let z = acceleration.z
            
            let magnitude = sqrt(x*x + y*y + z*z)
            let adjustedAmplifiedMagnitude = pow(magnitude, 5) - 1 //Substract 1 to align vertically on x-axis
            let roundedValue = round(adjustedAmplifiedMagnitude / self.quantisationStep) * self.quantisationStep
            
            //println("Magnitude: \(magnitude) shortAvg: \(shortAverage) longAvg: \(longAverage) Acc.: \(self.accelerating)")
            dispatch_async(dispatch_get_main_queue()) {
                self.onAccelerationMeasured(x,y,z,roundedValue)
            }
            
            self.shortBuffer.put(magnitude);
            self.longBuffer.put(magnitude);
            
            let shortAverage = self.shortBuffer.getAverage()
            let longAverage = self.longBuffer.getAverage()
            
            if !self.accelerating && (shortAverage > longAverage * 1.1) {
                self.accelerating = true
                self.steps++
                dispatch_sync(dispatch_get_main_queue()) {
                    self.onStep()
                }
            }
            
            if self.accelerating && shortAverage < longAverage * 0.9 {
                self.accelerating = false;
            }
        }
    }
    
    func stop() {
        accelerometer.stopAccelerometerUpdates()
        stepQueue.cancelAllOperations()
    }
    
    func reset(){
        stop();
        steps = 0
    }
}
