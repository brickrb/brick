module Brick
  class Installer
    include Config::Mixin

    # @return [Brickfile] The Brickfile specification that contains the information
    #         of the Bricks that should be installed.
    #
    attr_reader :brickfile

    # @param  [Brickfile]  brickfile     @see brickfile
    #
    def initialize(brickfile)
      @brickfile  = brickfile
    end

    # Install the Bricks!
    #
    # The installation process of is mostly linear with few minor complications
    # to keep in mind:
    #
    # @return [void]
    #
    def install!
      # Resolve Dependencies
        UI.puts "Analyzing dependencies"
        analyze

      # Download Dependencies
        UI.puts "Downloading dependencies"
        install_brick_sources
    end

    #-------------------------------------------------------------------------#

    public

    # @!group Installation results

    # @return [Array<String>] The Bricks that should be installed.
    #
    attr_accessor :names_of_bricks_to_install

    # @return [Array<Specification>] The specifications that where installed.
    #
    attr_accessor :installed_specs

    #-------------------------------------------------------------------------#

    private

    # @!group Installation steps

    # @return [void]
    #
    def analyze
      @brickfile.dependencies.for_each do |dependency|
      end
    end

    # Downloads, installs the documentation and cleans the sources of the Bricks
    # which need to be installed.
    #
    # @return [void]
    #
    def install_brick_sources
    end

  end
end
