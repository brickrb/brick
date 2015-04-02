module Brick
  require 'brick/gem_version'

  autoload :Command,       'brick/command'
  autoload :Config,        'brick/config'
  autoload :Dependency,    'brick/dependency'
  autoload :Spec,          'brick/specification'
  autoload :Specification, 'brick/specification'
  autoload :Version,       'brick/version'

  # Require UI after everything else to reset UI
  require 'brick/ui'
end