platform :ios, '13.0'

target 'SampleApp' do
	use_frameworks!

	pod 'Eureka', '5.3.3'
	pod 'SnapKit', '5.0.1'
	pod 'SwiftMessages', '9.0.2'
	pod 'ApiRTCSDK', '0.0.9'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
		end
	end
end
