# LibGroupMe

## A hacky Swift framework experiment

### Uses:
- [GroupMe](https://dev.groupme.com)'s public REST API
- [Alamofire](https://github.com/Alamofire/Alamofire) for networking
- [YapDatabase](https://github.com/yapstudios/YapDatabase) as a network cache 
- [Quick](https://github.com/quick/quick) and [Nimble](https://github.com/quick/nimble) for BDD-style testing
- [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) for mocking HTTP responses


## To get started:
- Install [CocoaPods](http://cocoapods.org/), then 
````
[LibGroupMe] ➤ pod install
[LibGroupMe] ➤ open LibGroupMe.xcworkspace
````

## To run the tests:

- Hit ⌘U to in Xcode
- You can also run tests on the command line, using a long `xcodebuild` command build that lives in `build.sh`:

````
[LibGroupMe] ➤ ./build.sh clean test
````
*(the raw `xcodebuild` output is pretty ugly. try piping it to [xcpretty](https://github.com/supermarin/xcpretty))*


## To integrate with other apps:

in your Podfile, add something like:

````
pod 'LibGroupMe', :git => 'https://github.com/jonbalbarin/LibGroupMe.git'
````
for OS X projects, or

````
pod 'LibGroupMe_iOS', :git => 'https://github.com/jonbalbarin/LibGroupMe.git'
````

for iOS projects
