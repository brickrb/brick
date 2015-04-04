module Brick
  require 'brick/gem_version'

  # Core Functionality
    autoload :Version,       'brick/version'
    autoload :Requirement,   'brick/requirement'
    autoload :Dependency,    'brick/dependency'
    autoload :Spec,          'brick/specification'
    autoload :Specification, 'brick/specification'

  # User Funtionality
    autoload :Command,       'brick/command'
    autoload :Config,        'brick/config'

  # Require UI after everything else to reset UI
    require 'brick/ui'
end