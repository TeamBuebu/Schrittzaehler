import Foundation

public class RingBuffer {
    private var buffer: [Double]!
    private var capacity: Int
    private var current: Int = 0
    private var count: Int = 0
    
    init(capacity: Int) {
        self.capacity = capacity
        reset()
    }
    
    public func reset(){
        buffer = Array<Double>(count: capacity, repeatedValue: 0.0)
        count = 0
    }
    
    public func put(f: Double) {
        buffer[current] = f
        current++
        count++
        current = current % capacity
    }
    
    public func maxValue() -> Double {
        return buffer.maxElement()!
    }
    
    public func getAverage() -> Double {
        let sum = buffer.reduce(0) {
            $0 + $1
        }
        return sum / Double(min(count,capacity))
    }
}