Pod::Spec.new do |s|
  s.name = 'HTTPRouter'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'HTTP router for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/HTTPRouter'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/HTTPRouter.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'HTTPRouter/**/*.swift'
  s.dependency 'HTTP'
  s.dependency 'POSIXRegex'

  s.requires_arc = true
end