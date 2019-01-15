Pod::Spec.new do |s|
  s.name         = "SGDebugMode"
  s.version      = "1.0.0"
  s.summary      = "Easy to add debug mode config items to your app."
  s.description  = <<-DESC
  Easy to add debug mode config items to your app. For example, device information, application information, user information, web link address, network api address, debug configuration items, etc.
                   DESC
  s.homepage     = "https://github.com/johnnylius/SGDebugMode"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "liuhuan" => "lh621@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/johnnylius/SGDebugMode.git", :tag => s.version.to_s }
  s.source_files  = "SGDebugMode/**/*.{h,m}"
  s.public_header_files = "SGDebugMode/**/*.h"
  s.requires_arc = true
end
