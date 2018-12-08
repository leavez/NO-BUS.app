Pod::Spec.new do |s|
    s.name             = 'ChinaShift'
    s.version          = '0.1.0'
    s.summary          = 'coordinates'

    s.description      = <<-DESC
      xxx
    DESC

    s.homepage         = 'https://xxx.com'
    s.license          = { :type => 'MIT' }
    s.author           = 'xxx@xxx.com'
    s.source           = { :git => 'git:xxx.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'
    s.source_files = '*.{h,m}'
    s.swift_version = "4.0"
end
