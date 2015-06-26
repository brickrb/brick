module Brick
  class Command
    # Provides support for the common behaviour of the `install` and `update`
    # commands.
    #
    module Project
      include Config::Mixin

      module Options
        def options
          [].concat(super)
        end
      end

      def initialize(argv)
        super
      end

      # Runs the installer.
      #
      # @param  [Hash, Boolean, nil] update
      #         Bricks that have been requested to be updated or true if all Bricks
      #         should be updated
      #
      # @return [void]
      #
      def run_install_with_update(update)
        installer = Installer.new(brickfile)
        installer.update = update
        installer.install!
      end
    end

    #-------------------------------------------------------------------------#

    class Install < Command
      include Project

      self.summary = 'Install project dependencies'

      self.description = <<-DESC
        Downloads all dependencies defined in `Brickfile`.
      DESC

      def run
        verify_brickfile_exists!
        run_install_with_update(false)
      end
    end
  end
end
