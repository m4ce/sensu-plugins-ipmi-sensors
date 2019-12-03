lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'

if RUBY_VERSION < '2.0.0'
  require 'sensu-plugins-ipmi-sensors'
else
  require_relative 'lib/sensu-plugins-ipmi-sensors'
end

Gem::Specification.new do |s|
  s.authors                = ['Matteo Cerutti', 'Dan Ragnar']
  s.date                   = Date.today.to_s
  s.description            = 'This plugin provides facilities for monitoring IPMI sensors'
  s.email                  = '<matteo.cerutti@hotmail.co.uk>'
  s.executables            = Dir.glob('bin/**/*').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md CHANGELOG.md)
  s.homepage               = 'https://github.com/danragnar/sensu-plugins-ipmi-sensors'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer'         => '@m4ce',
                               'development_status' => 'active',
                               'production_status'  => 'devel',
                               'release_draft'      => 'false',
                               'release_prerelease' => 'false'
                              }
  s.name                   = 'sensu-plugins-ipmi-sensors'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 1.9.3'
  s.summary                = 'Sensu plugins for monitoring IPMI sensors'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = SensuPluginsIPMISensors::Version::VER_STRING

  s.add_runtime_dependency 'sensu-plugin',   '~> 4.0'
  s.add_runtime_dependency 'rubyipmi',       '0.10.0'
end
