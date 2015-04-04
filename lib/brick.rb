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
    autoload :Spec,          'brick/specification'
    autoload :Specification, 'brick/specification'

  # User Funtionality
    autoload :Command,       'brick/command'
    autoload :Config,        'brick/config'

  # Require UI after everything else to reset UI
    require 'brick/ui'
end