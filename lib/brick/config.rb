require 'pathname'

module Brick
  # This is the storage location for Brick's global configuration.

  class Config
    def self.instance
      @instance ||= new
    end

    def self.instance=(instance)
      @instance = instance
    end

    attr_accessor :repos_dir, :verbose, :silent
    alias_method :verbose?, :verbose
    alias_method :silent?,  :silent

    def initialize
      @repos_dir = Pathname.new(File.expand_path("~/.bricks"))
      @verbose = false
      @silent = false
    end

    def project_root
      Pathname.pwd
    end

    def project_brickfile
      unless @project_brickfile
        @project_brickfile = project_root + 'Brickfile'
        unless @project_brickfile.exist?
          @project_brickfile = project_root.glob('*.brickspec').first
        end
      end
      @project_brickfile
    end

    module Mixin
      def config
        Config.instance
      end
    end
  end
end