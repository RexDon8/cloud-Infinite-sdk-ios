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
  s.source           = { :git => 'https://github.com/tencentyun/cloud-Infinite-sdk-ios/CloudInfinite',:branch => 'develop'}
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'
  s.static_framework = true
  
#  图片链接组装模块
  s.default_subspec  = 'CloudInfinite'
  s.subspec 'CloudInfinite' do |default|
    default.source_files = 'Pod/Classes/CloudInfinite/*';
  end
  
# 图片下载模块
  s.subspec 'Loader' do |loader|
    loader.source_files = 'Pod/Classes/Loader/*';
    loader.dependency 'QCloudCore'
    loader.vendored_frameworks = 'CloudInfinite'
  end
    
# TPG解码模块
  s.subspec 'TPG' do |tpg|
    tpg.source_files = 'Pod/Classes/TPG/*',
                       'Pod/Classes/TPG/TPGDecoder/*',
                       'Pod/Classes/TPG/TPGDecoder/include/*';
    tpg.vendored_libraries='Pod/Classes/TPG/TPGDecoder/*.a'
  end
  
# SDWebImage 支持TPG图片加载模块
  s.subspec 'SDWebImage-TPG' do |sdtpg|
    sdtpg.source_files = 'Pod/Classes/SDWebImage-TPG/*';
    sdtpg.vendored_framework = 'TPG'
    sdtpg.dependency 'SDWebImage'
  end
  
end
