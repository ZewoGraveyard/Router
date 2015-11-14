Pod::Spec.new do |s|
  s.name = 'Spell'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Aeon based HTTP Router for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Spell'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Spell.git', :tag => 'v0.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Dependencies/Belle/*.c',
                   'Dependencies/Gamut/*.c',
                   'Dependencies/Incandescence/*.c',
                   'Dependencies/Tide/*.c',
                   'Currents/**/*.swift',
                   'Kalopsia/**/*.swift',
                   'Luminescence/**/*.swift',
                   'Aeon/**/*.swift',
                   'Spell/**/*.swift'

  s.xcconfig =  {
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Spectrum/Dependencies'
  }

  s.preserve_paths = 'Dependencies/*'

  s.requires_arc = true
end