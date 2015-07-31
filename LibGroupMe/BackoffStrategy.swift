import Foundation

public class BackoffStrategy {
    
    public var delay: NSTimeInterval
    var maxDelay: NSTimeInterval
    var multiplier: NSTimeInterval
    private var lastDelay: NSTimeInterval
    private var numberOfTries: NSInteger
    private var maxNumberOfTries: NSInteger
    
    private(set) public var backoffStatusCode: Int
    private(set) public var finishedStatusCode: Int

    
    required public init(backoffStatusCode:NSInteger, finishedStatusCode: NSInteger, maxNumberOfTries: NSInteger, multiplier: Double) {
        self.delay = 1
        self.multiplier = (multiplier >= 1) ? multiplier : 1
        self.lastDelay = 0
        self.maxDelay = 10
        self.maxNumberOfTries = maxNumberOfTries
        self.numberOfTries = 0
        
        self.backoffStatusCode = backoffStatusCode
        self.finishedStatusCode = finishedStatusCode
    }
    
    public func nextDelayInterval() -> NSTimeInterval {
        self.numberOfTries++
        if self.numberOfTries > maxNumberOfTries {
            return -1
        }
        
        if (self.multiplier > 1 && self.numberOfTries > 1) {
            self.lastDelay = self.lastDelay * multiplier
        } else {
            self.lastDelay = self.delay ;
        }
        
        return self.lastDelay
    }
}