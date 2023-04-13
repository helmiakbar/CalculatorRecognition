# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def pods_for_calculatorRecognition
    pod 'CryptoSwift', '~> 1.7.0'
    pod 'SkeletonView', :git => 'https://github.com/Juanpe/SkeletonView', :tag => '1.8.2'
end

target 'AppGreenCameraRoll' do
  use_frameworks!

  # Pods for AppGreenCameraRoll
    pods_for_calculatorRecognition
end

target 'AppGreenFilesystem' do
  use_frameworks!

  # Pods for AppGreenFilesystem
    pods_for_calculatorRecognition
end

target 'AppRedBuiltInCameraInfo' do
  use_frameworks!

  # Pods for AppRedBuiltInCameraInfo
    pods_for_calculatorRecognition
end

target 'AppRedCameraRoll' do
  use_frameworks!

  # Pods for AppRedCameraRoll
    pods_for_calculatorRecognition
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end

