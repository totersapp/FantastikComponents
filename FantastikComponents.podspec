Pod::Spec.new do |s|
  s.name             = 'FantastikComponents'
  s.version          = '0.1.0'
  s.summary          = 'FantastikComponents. Currently it has implementation of StickyHeaderTableView'

  s.description      = <<-DESC
  'FantastikComponents. Currently it has implementation of StickyHeaderTableView'
  DESC

  s.homepage         = 'https://github.com/totersapp/FantastikComponents'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitry Koryakin' => 'dmitry.koryakin@gmail.com' }
  s.source           = { :git => 'https://github.com/totersapp/FantastikComponents.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.source_files = 'FantastikComponents/Classes/**/*'
end
