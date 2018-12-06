# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'NoBus' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod "fucking-beijing-bus-api", :git => "https://github.com/leavez/fucking-beijing-bus-api.git", :tag => "1.0.4"
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod "RxGesture"
  pod 'SteviaLayout'
  
  # pod 'MKRingProgressView'
  # pod 'THLabel'

  target 'NoBusTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
  end

end
