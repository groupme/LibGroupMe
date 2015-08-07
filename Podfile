source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def import_pods
  pod 'LibGroupMe', :path => '.' 

  pod 'Quick', '~> 0.3.1'
  pod 'Nimble', '~> 0.4.1'
  pod 'OHHTTPStubs', '~> 4.0.1'
end

target :LibGroupMe_iOS do
  platform :ios, '8.0'
  import_pods
end

target :LibGroupMe do
  platform :osx, '10.10'
  link_with 'LibGroupMeTests'
  import_pods
end
