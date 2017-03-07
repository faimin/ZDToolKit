
Pod::Spec.new do |s|

  s.name         = 'ZDToolKit'
  s.version      = '0.0.2'
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
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source       = {
    :git =>'https://github.com/faimin/ZDToolKit.git', 
    :tag => s.version.to_s
  }

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
      sss.dependency 'SDWebImage', '~> 3.8.2'
    end
  end

  s.subspec 'ZDMacros' do |ss|
    ss.source_files = 'ZDToolKit/ZDMacros/*.{h,m}'
  end

  s.subspec 'ZDRuntime' do |ss|
    ss.source_files = 'ZDToolKit/ZDRuntime/*.{h,m}'
  end

  no_arc_source_files = 'ZDToolKit/ZDTools/ZDSafe.{h,m}'

  s.subspec 'ZDTools' do |ss|
    ss.source_files = 'ZDToolKit/ZDTools/*.{h,m}'
    ss.exclude_files = no_arc_source_files

    ss.subspec 'BackButtonHandle' do |sss|
      sss.source_files = 'ZDToolKit/ZDTools/BackButtonHandle/*.{h,m}'
    end
  end

  s.subspec 'no-arc' do |ss|
    ss.requires_arc = false
    ss.source_files = no_arc_source_files
  end

end
