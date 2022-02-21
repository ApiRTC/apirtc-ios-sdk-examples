platform :ios, '14.0'

use_frameworks!

inhibit_all_warnings!

workspace 'SampleApp.xcworkspace'

project 'SampleApp.xcodeproj'

target 'SampleApp' do
	pod 'Eureka', '5.3.4'
	pod 'SnapKit', '5.0.1'
	pod 'SwiftMessages', '9.0.6'
	pod 'ApiRTCSDK', '1.0.8'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
		end
	end
end
