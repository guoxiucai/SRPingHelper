Pod::Spec.new do |s|
  s.name         = 'SRPingHelper'
  s.summary      = 'An encapsulation of Apple's SimplePing, support RTT and packetsloss result.'
  s.version      = '0.1.0'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = {'guoqingwei' => 'qqingweihao@163.com'}
  s.social_media_url = 'https://github.com/qqingweihao/SRPingHelper'
  s.homepage     = 'https://github.com/qqingweihao/SRPingHelper'
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => 'https://github.com/qqingweihao/SRPingHelper.git', :tag => s.version }
  s.requires_arc = true
  s.source_files = 'SRPingHelper/**/*.{h,m}'

end
