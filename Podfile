platform :ios, '13.0'

use_frameworks!

workspace 'SampleApp.xcworkspace'

inhibit_all_warnings!

project 'SampleApp.xcodeproj'
#project '../ios-apirtc-sdk/ApiRTCSDK.xcodeproj'

abstract_target 'App' do

    pod 'RxSwift', '6.1.0'
    pod 'RxRelay', '6.1.0'
    pod 'GoogleWebRTC', '1.1.31999'
	pod 'CocoaAsyncSocket', '7.6.5'
	pod 'Socket.IO-Client-Swift', '16.0.1'
	pod 'Alamofire', '5.4.3'
	pod 'Resolver', '1.4.3'
    pod 'ReactorKit', '3.0.0'
    
	target 'SampleApp' do

		pod 'Eureka', '5.3.3'
		pod 'SnapKit', '5.0.1'
		pod 'SwiftMessages', '9.0.2'
		#pod 'ApiRTCSDK', '0.0.10'
	end

	target 'ApiRTCSDK' do
	    project '../ios-apirtc-sdk/ApiRTCSDK.xcodeproj'
	end

end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
		end
	end
end
