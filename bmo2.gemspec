Gem::Specification.new do |s|
  s.name        = 'bmo2'
  s.version     = '0.1.1'
  s.date        = '2015-08-10'
  s.summary     = "Bmo2 is a simple server helper"
  s.description = "Bmo2 can order links, path or whatewer you want!"
  s.authors     = ["Peter Boriskin"]
  s.email       = 'x66w@ya.ru'
  s.executables = ["bmo2"]
  s.default_executable = 'bmo2'
  s.add_dependency('yajl-ruby', '~> 1.2', '>= 1.2.1')
  s.files = %w[
    LICENSE.md
    README.md
    bin/bmo2
    lib/bmo2.rb
    lib/bmo2/color.rb
    lib/bmo2/command.rb
    lib/bmo2/ext/symbol.rb
    lib/bmo2/item.rb
    lib/bmo2/list.rb
    lib/bmo2/platform.rb
    lib/bmo2/storage.rb

  ]
  s.homepage    =
    'https://github.com/bmo2/gem'
  s.license       = 'MIT'
end
