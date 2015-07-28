source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def application_pods
	pod 'Alamofire', '~> 1.2'
	pod 'YapDatabase', '~> 2.6'
end

def test_pods
	pod 'Quick', '~> 0.3.1'
	pod 'Nimble', '~> 0.4.1'
	pod 'OHHTTPStubs', '~> 4.0.1'
end


target :LibGroupMe do
	application_pods
end

target :LibGroupMe_iOS do
	application_pods
end

target :LibGroupMeTests do
	application_pods
	test_pods
end
