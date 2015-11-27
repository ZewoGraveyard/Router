Pod::Spec.new do |s|
  s.name = 'Spell'
  s.version = '0.2.1'
  s.license = 'MIT'
  s.summary = 'HTTP router for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Spell'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Spell.git', :tag => 'v0.2.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Spell/**/*.swift'
  s.dependency 'Otherside', '0.1.1'
  s.dependency 'Spectrum', '0.2'

  s.requires_arc = true
end