require 'brick/vendored_claide'

module Brick
  class PlainInformative
    include CLAide::InformativeError
  end

  class Command < CLAide::Command
    self.abstract_command = true
    self.command = 'brick'
    self.version = VERSION
    self.description = 'Brick, the Ruby library package manager.'
    self.plugin_prefixes = %w(claide brick)
  end
end