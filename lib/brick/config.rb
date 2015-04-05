require 'pathname'

module Brick
  # This is the storage location for Brick's global configuration.

  class Config

    attr_accessor :repos_dir, :verbose, :silent
    alias_method :verbose?, :verbose
    alias_method :silent?,  :silent

    def initialize
      @repos_dir = Pathname.new(File.expand_path("~/.bricks"))
      @verbose = false
      @silent = false
    end

    def project_root
      @project_root ||= Pathname.pwd
    end

    def project_brickfile
      @project_brickfile ||= project_root + 'Brickfile'
    end

    # @return [Podfile] The Podfile to use for the current execution.
    #
    def brickfile
      @brickfile ||= begin
        Brickfile.from_file(project_brickfile) if project_brickfile.exist?
      end
    end
    attr_writer :brickfile

    def self.instance
      @instance ||= new
    end

    def self.instance=(instance)
      @instance = instance
    end

    module Mixin
      def config
        Config.instance
      end
    end

    public

    # @return [Array<String>] The filenames that the Brickfile can have ordered
    #         by priority.
    #
    BRICKFILE_NAMES = [
      'Brickfile'
    ].freeze

    public

    # Returns the path of the Brickfile in the given dir if any exists.
    #
    # @param  [Pathname] dir
    #         The directory where to look for the Brickfile.
    #
    # @return [Pathname] The path of the Brickfile.
    # @return [Nil] If not Brickfile was found in the given dir
    #
    def brickfile_path_in_dir(dir)
      BRICKFILE_NAMES.each do |filename|
        candidate = dir + filename
        if candidate.exist?
          return candidate
        end
      end
      nil
    end
  end
end