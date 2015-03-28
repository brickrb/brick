module Brick
  require 'brick/gem_version'

  autoload :Command,       'brick/command'
  autoload :Specification, 'brick/specification'

  # Require UI after everything else to reset UI
  require 'brick/ui'
end