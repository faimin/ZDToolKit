source 'https://github.com/CocoaPods/Specs.git'

Pod::Spec.new do |s|

  s.name         = 'ZDToolKit'
  s.version      = '0.0.1'
  s.summary      = 'awesome development iOS tools（Objective-C）'
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
    tag: s.version 
  }
  s.source_files = 'ZDToolKit', 
  'ZDToolKit/ZDAutoLayout/*.{h, m}', 
  'ZDToolKit/ZDBlock/*.{h, m}', 
  'ZDToolKit/ZDCategory/Foundation/*.{h, m}',
  'ZDToolKit/ZDCategory/UIKit/*.{h, m}', 
  'ZDToolKit/ZDMacros/*', 
  'ZDToolKit/ZDRuntime/*.{h, m}', 
  'ZDToolKit/ZDTools/*.{h, m}', 
  'ZDToolKit/ZDTools/RZCollectionTableView/*.{h, m}', 
  'ZDToolKit/ZDTools/NavigationBarTool/BackButtonHandle/*.{h, m}', 
  'ZDToolKit/ZDTools/NavigationBarTool/KMNavigationBarTransition/*.{h, m}'
  s.exclude_files = 'ZDToolKit/ZDTools/NavigationBarTool/ZDNavigationController.{h,m}'

end
