#
# Be sure to run `pod lib lint CloudInfinite.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CloudInfinite"
  s.version          = "1.0.0"
  s.summary          = "CloudInfinite 腾讯云iOS-SDK组件"

  s.description      = <<-DESC
  数据万象sdk
                       DESC
  
  s.homepage         = "https://cloud.tencent.com/"
  s.license          = 'MIT'
  s.author           = { 'garenwang' => 'garenwang@tencent.com' }
  s.source           = { :git => 'https://github.com/tencentyun/cloud-Infinite-sdk-ios.git',:branch => 'master'}
  
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.frameworks = 'UIKit','Foundation','ImageIO'
  s.libraries = 'z','c++'
  s.xcconfig = {
     "OTHER_LDFLAGS" => "$(inherited) -ObjC -all_load -force_load",
   }
#  图片链接组装模块
  s.default_subspec  = 'CloudInfinite'
  s.subspec 'CloudInfinite' do |default|
    default.source_files = 'Pod/Classes/CloudInfinite/*';
  end
  
# 图片下载模块
  s.subspec 'Loader' do |loader|
    loader.source_files = 'Pod/Classes/Loader/*';
    loader.dependency 'QCloudCore';
    loader.dependency 'CloudInfinite/CloudInfinite';
  end
    
# TPG解码模块
  s.subspec 'TPG' do |tpg|
    
    tpg.source_files = 'Pod/Classes/TPG/*',
                       'Pod/Classes/TPG/TPGDecoder/*',
                       'Pod/Classes/TPG/TPGDecoder/include/*';
     tpg.vendored_libraries='Pod/Classes/TPG/TPGDecoder/*.a';
  end
  
# SDWebImage 支持TPG图片加载模块
  s.subspec 'SDWebImage-TPG' do |sdtpg|
    sdtpg.source_files = 'Pod/Classes/SDWebImage-TPG/*';
    sdtpg.dependency 'CloudInfinite/TPG';
    sdtpg.dependency 'SDWebImage';
  end
  
end
