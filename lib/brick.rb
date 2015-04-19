module Brick
  require 'brick/gem_version'

  # Indicates a runtime error **not** caused by a bug.
  #
  class PlainInformative < StandardError; end

  # Indicates a user error.
  #
  class Informative < PlainInformative; end

  # Core Functionality
    autoload :Version,       'brick/version'
    autoload :Requirement,   'brick/requirement'
    autoload :Dependency,    'brick/dependency'
    autoload :Specification, 'brick/specification'

  # Everything else
    autoload :Command,       'brick/command'
    autoload :Config,        'brick/config'
    autoload :Brickfile,     'brick/brickfile'
    autoload :Installer,     'brick/installer'

  # Require UI after everything else to reset UI
    require 'brick/ui'

  Spec = Specification
end