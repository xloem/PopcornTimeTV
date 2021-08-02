use_frameworks!

source 'https://github.com/CocoaPods/Specs'

target 'PopcornTimeiOS' do
    platform :ios, '14.5'
    pod 'google-cast-sdk', '~> 4.4'
    pod 'OBSlider', '~> 1.1.1'
    pod 'MobileVLCKit', '~> 3.3.17'
end

target 'PopcornTimetvOS' do
    platform :tvos, '14.5'
    pod 'TVVLCKit', '~> 3.3.17'
end

target 'PopcornTimetvOS SwiftUI' do
    platform :tvos, '14.5'
    pod 'TVVLCKit', '~> 3.3.17'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
    
#    installer.pods_project.build_configurations.each do |config|
#        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#    end
end
