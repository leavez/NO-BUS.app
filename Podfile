
plugin 'cocoapods-static-swift-framework'

platform :ios, '12.0'
use_frameworks!

target 'NoBus' do
  pod "fucking-beijing-bus-api", :git => "https://github.com/leavez/fucking-beijing-bus-api.git", :tag => "1.0.4"
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod "RxGesture"
  pod "RxCoreLocation"
  pod 'SteviaLayout'
  
  # pod 'MKRingProgressView'
  # pod 'THLabel'
  pod "ChinaShift", :path => "libs/ChinaShift"

  target 'NoBusTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

end
