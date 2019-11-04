Pod::Spec.new do |spec|


  spec.name         = "XHAudio"
  spec.version      = "0.0.1"
  spec.summary      = "XHAudio，音频播放或者录制。"
  
  spec.description  = <<-DESC
                    XHAudio是一个音频播放器，对系统音频播放进行组装，播放调用更加简单。对系统录音进行组装，录音更加方便。
                   DESC

  spec.homepage     = "https://github.com/xh1130485186/XHAudio.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "xianghong" => "1130485186@qq.com" }

  spec.platform     = :ios, "8.0"

  spec.source       = { :git => "https://github.com/xh1130485186/XHAudio.git", :tag => spec.version }

  spec.resource  = "XHAudio/xh.audio.bundle"

  spec.requires_arc = true
  
  # spec.public_header_files = 'XHKit.h'
  spec.source_files = 'XHAudio/*.{h,m}'

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
