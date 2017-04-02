source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Alamofire', '~> 3.0'

target 'Poaster' do
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
end

pod 'Toucan'

pod 'Bolts'
pod 'FBSDKCoreKit'
pod 'FBSDKShareKit'
pod 'FBSDKLoginKit'

pod 'BXProgressHUD'

pod 'IQKeyboardManagerSwift'

pod 'Firebase/Core'
pod 'Firebase/Messaging'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
