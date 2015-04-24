require 'pathname'

module Brick
  # This is the storage location for Brick's global configuration.

  class Config

    # The default settings for the configuration.
    #
    # Users can specify custom settings in `~/.bricks/config.yaml`.
    # An example of the contents of this file might look like:
    #
    #     ---
    #     verbose: true
    #     silent: false
    #
    DEFAULTS = {
      :verbose             => false,
      :silent              => false,
    }

    #--------------------------------------#

    attr_accessor :repos_dir, :verbose, :silent
    alias_method :verbose?, :verbose
    alias_method :silent?,  :silent

    def initialize
      configure_with(DEFAULTS)

      if user_settings_file.exist?
        require 'yaml'
        user_settings = YAML.load_file(user_settings_file)
        configure_with(user_settings)
      end
    end

    # @return [Pathname] the directory where the Bricks are stored.
    #
    def repos_dir
      @repos_dir ||= Pathname.new(ENV['HOME'] + "/.bricks")
    end
    attr_writer :repos_dir

    def project_root
      @project_root ||= Pathname.pwd
    end
    attr_writer :project_root

    def project_brickfile
      @project_brickfile ||= project_root + 'Brickfile'
    end
    attr_writer :project_brickfile

    # @return [Brickfile] The Brickfile to use for the current execution.
    #
    def brickfile
      @brickfile ||= begin
        Brickfile.from_file(project_brickfile) if project_brickfile.exist?
      end
    end
    attr_writer :brickfile

    # private

    # @return [Pathname] The path of the file which contains the user settings.
    #
    def user_settings_file
      Pathname.new(ENV['HOME'] + "/.bricks/config.yaml")
    end

    # Sets the values of the attributes with the given hash.
    #
    # @param  [Hash{String,Symbol => Object}] values_by_key
    #         The values of the attributes grouped by key.
    #
    # @return [void]
    #
    def configure_with(values_by_key)
      return unless values_by_key
      values_by_key.each do |key, value|
        self.instance_variable_set("@#{key}", value)
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

  end
end