import LibGroupMe
import Quick
import Nimble
import OHHTTPStubs

class BackoffStrategySpec: QuickSpec {
    override func spec() {
        describe("a linear backoff") {
            it("should return the same interval each time, until hitting the max") {
                let back = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 200, maxNumberOfTries: 4, multiplier: 1)
                expect(back.nextDelayInterval()).to(equal(1))
                expect(back.nextDelayInterval()).to(equal(1))
                expect(back.nextDelayInterval()).to(equal(1))
                expect(back.nextDelayInterval()).to(equal(1))
                expect(back.nextDelayInterval()).to(equal(-1))
                expect(back.nextDelayInterval()).to(equal(-1))
                
                let backTwo = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 200, maxNumberOfTries: 2, multiplier: 1)
                backTwo.delay = 2
                expect(backTwo.nextDelayInterval()).to(equal(2))
                expect(backTwo.nextDelayInterval()).to(equal(2))
                expect(backTwo.nextDelayInterval()).to(equal(-1))
            }
        }
        describe("an exponential backoff") {
            it("should return the an increasing interval each time, until hitting the max") {
                let back = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 200, maxNumberOfTries: 10, multiplier: 1.5)
                expect(back.nextDelayInterval()).to(equal(1))
                expect(back.nextDelayInterval()).to(beCloseTo(1.5))
                expect(back.nextDelayInterval()).to(beCloseTo(2.25))
                expect(back.nextDelayInterval()).to(beCloseTo(3.375))
                expect(back.nextDelayInterval()).to(beCloseTo(5.0625))
                expect(back.nextDelayInterval()).to(beCloseTo(7.5938))
                expect(back.nextDelayInterval()).to(beCloseTo(11.3906))
                expect(back.nextDelayInterval()).to(beCloseTo(17.0859))
                expect(back.nextDelayInterval()).to(beCloseTo(25.6289))
                expect(back.nextDelayInterval()).to(beCloseTo(38.4434))
                expect(back.nextDelayInterval()).to(beCloseTo(-1))
                expect(back.nextDelayInterval()).to(beCloseTo(-1))
                expect(back.nextDelayInterval()).to(beCloseTo(-1))
                
                let backFive = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 200, maxNumberOfTries: 4, multiplier: 3.2)
                backFive.delay = 2.1
                // floating points, how do they work?
                expect(backFive.nextDelayInterval()).to(beCloseTo(2.1))
                expect(backFive.nextDelayInterval()).to(beCloseTo(6.720))
                expect(backFive.nextDelayInterval()).to(beCloseTo(21.504))
                expect(backFive.nextDelayInterval()).to(beCloseTo(68.8128))
                expect(backFive.nextDelayInterval()).to(equal(-1))
                expect(backFive.nextDelayInterval()).to(equal(-1))
            }
        }
    }
}
