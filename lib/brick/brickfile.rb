module Brick
  class Brickfile

    # Returns an instance of Brick::Brickfile for an instance of Pathname
    #
    # @param  [Pathname] An instance of the Pathname class, with the path for the Brickfile you want to use
    #
    # @return [Brickfile] An instance of the Brick::Brickfile class, with the contents of the Brickfile you want to use
    #
    def self.from_file(path)
      brickfile = Brickfile.new do
        eval(path.read, nil, path.to_s)
      end
      brickfile.defined_in_file = path
      brickfile.validate!
      brickfile
    end

    def initialize(&block)
      @dependencies = []
      instance_eval(&block)
    end

    # Specifies the platform for the Brickfile.
    #
    # This can be either `:jruby` for JRuby, `:ree` for Ruby Enterprise Edition,
    # or `:rbx` for Rubinius
    #
    def platform(platform = nil)
      platform ? @platform = platform : @platform
    end

    # Specifies a dependency of the project.
    #
    # A dependency requirement is defined by the name of the Brick and _optionally_
    # a list of version requirements.
    #
    #
    # When starting out with a project it is likely that you will want to use the
    # latest version of a Brick. If this is the case, simply omit the version
    # requirements.
    #
    #   brick 'SSZipArchive'
    #
    #
    # Later on in the project you may want to freeze to a specific version of a
    # Brick, in which case you can specify that version number.
    #
    #   brick 'Objection', '0.9'
    #
    #
    # Besides no version, or a specific one, it is also possible to use operators:
    #
    # * `> 0.1`    Any version higher than 0.1
    # * `>= 0.1`   Version 0.1 and any higher version
    # * `< 0.1`    Any version lower than 0.1
    # * `<= 0.1`   Version 0.1 and any lower version
    # * `~> 0.1.2` Version 0.1.2 and the versions upto 0.2, not including 0.2
    #
    #
    # Finally, a list of version requirements can be specified for even more fine
    # grained control.
    def brick(name, *version_requirements)
      @dependencies << Dependency.new(name, *version_requirements)
    end

    attr_reader :dependencies

    def brickfile?
      true
    end

    attr_accessor :defined_in_file

    def dependency_by_name(name)
      @dependencies.find { |d| d.name == name }
    end

    def validate!
      lines = []
      if @platform
        unless [:jruby, :ree, :rbx].include?(@platform)
          lines << "* the `platform` attribute should be either `:jruby`, `:ree` or `:rbx`"
        end
      end
      lines << "* no dependencies were specified, which is, well, kinda pointless" if @dependencies.empty?
      raise(Informative, (["The Brickfile at `#{@defined_in_file}' is invalid:"] + lines).join("\n")) unless lines.empty?
    end
  end
end
