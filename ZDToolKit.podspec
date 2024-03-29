
Pod::Spec.new do |s|

  s.name         = 'ZDToolKit'
  s.version      = '0.0.5'
  s.summary      = 'awesome iOS development tools（Objective-C）'
  s.description  = <<-DESC
                   collect some iOS development tools, e.g: category、block、runtime、subclass、macro, and so on...
                   DESC

  s.homepage     = 'https://github.com/faimin'
  s.license      = { 
    :type => 'MIT', 
    :file => 'LICENSE' 
  }
  s.author       = { 'Zero.D.Saber' => 'fuxianchao@gmail.com' }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  # s.static_framework = true
  s.public_header_files = 'ZDToolKit/ZDToolKit.h'
  s.module_name  = 'ZDToolKit'
  s.pod_target_xcconfig = {
     'DEFINES_MODULE' => 'YES'
  }
  s.source       = {
    :git => 'https://github.com/faimin/ZDToolKit.git', 
    :tag => s.version.to_s
  }
  s.source_files = 'ZDToolKit/ZDToolKit.h'

  s.subspec 'ZDMacros' do |ss|
    ss.source_files = 'ZDToolKit/ZDMacros/*.{h,m}'
  end

  s.subspec 'ZDAutoLayout' do |ss|
    ss.source_files = 'ZDToolKit/ZDAutoLayout/*.{h,m}'
  end

  s.subspec 'ZDCategory' do |ss|
    ss.subspec 'Foundation' do |sss|
      sss.source_files = 'ZDToolKit/ZDCategory/Foundation/*.{h,m}'
      sss.frameworks = 'UIKit', 'Foundation', 'CoreText'
    end

    ss.subspec 'UIKit' do |sss|
      sss.source_files = 'ZDToolKit/ZDCategory/UIKit/*.{h,m}'
      sss.frameworks = 'UIKit', 'QuartzCore', 'CoreImage', 'CoreGraphics', 'ImageIO', 'CoreText', 'WebKit'
      sss.dependency 'ZDToolKit/ZDTools/ZDProxy'
    end

    ss.dependency 'ZDToolKit/ZDMacros'
  end

  s.subspec 'ZDSubclass' do |ss|
    ss.source_files = 'ZDToolKit/ZDSubclass/*.{h,m}'
    ss.dependency 'ZDToolKit/ZDTools/ZDProxy'
  end

  s.subspec 'ZDRuntime' do |ss|
    ss.source_files = 'ZDToolKit/ZDRuntime/*.{h,m}'
    ss.exclude_files = 'ZDToolKit/ZDRuntime/ZDBlockHook.{h,m}'
    #ss.dependency 'libffi-core'
  end

  # no_arc_source_files = 'ZDToolKit/ZDTools/ZDSafe.{h,m}'

  s.subspec 'ZDTools' do |ss|
    ss.source_files = 'ZDToolKit/ZDTools/*.{h,m}'
    # ss.exclude_files = no_arc_source_files

    ss.subspec 'ZDProxy' do |sss|
      sss.source_files = 'ZDToolKit/ZDTools/ZDProxy/*.{h,m}'
    end

    ss.subspec 'ZDPromise' do |sss|
      sss.source_files = 'ZDToolKit/ZDTools/ZDPromise/*.{h,m}'
    end

    ss.subspec 'ProtocolKit' do |sss|
      sss.source_files = 'ZDToolKit/ZDTools/ProtocolKit/*.{h,m}'
    end
  end

  s.subspec 'ZDDebug' do |ss|
    ss.source_files = 'ZDToolKit/ZDDebug/**/*.{h,m}'
  end

  s.subspec 'ZDMRC' do |ss|
    ss.requires_arc = false
    ss.source_files = 'ZDToolKit/ZDMRC/**/*.{h,m}'
  end

end
