require 'brick/vendored_claide'

module Brick
  class PlainInformative
    include CLAide::InformativeError
  end

  class Command < CLAide::Command
    require 'brick/command/init'
    require 'brick/command/spec'

    self.abstract_command = true
    self.command = 'brick'
    self.version = VERSION
    self.description = 'Brick, the Ruby library package manager.'
    self.plugin_prefixes = %w(claide brick)

    def self.options
      [
        ['--silent',   'Show nothing'],
      ].concat(super)
    end

    def self.run(argv)
      super(argv)
    end

    def initialize(argv)
      super
      config.silent = argv.flag?('silent', config.silent)
    end

    #-------------------------------------------------------------------------#

    include Config::Mixin

    private

    # Checks that the brickfile exists.
    #
    # @raise  If the brickfile does not exists.
    #
    # @return [void]
    #
    def verify_brickfile_exists!
      unless config.brickfile
        raise Informative, "No `Brickfile' found in the project directory."
      end
    end

  end
end