module Brick
  # The Dependency allows to specify dependencies of a {Brickfile} or a
  # {Specification} on a Brick. It stores the name of the dependency, and
  # version requirements.
  #
  class Dependency
    # @return [String] The name of the Brick described by this dependency.
    #
    attr_accessor :name

    # @overload   initialize(name, requirements)
    #
    #   @param    [String] name
    #             the name of the Brick.
    #
    #   @param    [Array, Version, String, Requirement] requirements
    #             an array specifying the version requirements of the
    #             dependency.
    #
    #   @example  Initialization with version requirements.
    #
    #             Dependency.new('rails')
    #             Dependency.new('rails', '~> 1.0')
    #             Dependency.new('rails', '>= 0.5', '< 0.7')
    #
    def initialize(name = nil, *requirements)
      if requirements.length == 1 && requirements.first.is_a?(Requirement)
        requirements = requirements.first
      end
      @name = name
      @requirement = Requirement.create(requirements)
    end

    # @return [Version] whether the dependency points to a specific version.
    #
    attr_accessor :specific_version

    # @return [Requirement] the requirement of this dependency (a set of
    #         one or more version restrictions).
    #
    # @todo   The specific version is stripped from head information because
    #         because its string representation would not parse. It would
    #         be better to add something like Version#display_string.
    #
    def requirement
      if specific_version
        Brick::Requirement.new(Version.new(specific_version.version))
      else
        @requirement
      end
    end

    # Checks if a dependency would be satisfied by the requirements of another
    # dependency.
    #
    # @param  [Dependency] other
    #         the other dependency.
    #
    # @note   This is used by the Lockfile to check if a stored dependency is
    #         still compatible with the Brickfile.
    #
    # @return [Bool] whether the dependency is compatible with the given one.
    #
    def compatible?(other)
      return false unless name == other.name

      other.requirement.requirements.all? do |_operator, version|
        requirement.satisfied_by? Version.new(version)
      end
    end

    # @return [Bool] whether the dependency is equal to another taking into
    #         account the loaded specification.
    #
    def ==(other)
      self.class == other.class &&
        name == other.name &&
        requirement == other.requirement
    end
    alias_method :eql?, :==

    #  @return [Fixnum] The hash value based on the name and on the
    #  requirements.
    #
    def hash
      name.hash ^ requirement.hash
    end

    # @return [Fixnum] How the dependency should be sorted respect to another
    #         one according to its name.
    #
    def <=>(other)
      name <=> other.name
    end

    # Merges the version requirements of the dependency with another one.
    #
    # @param  [Dependency] other
    #         the other dependency to merge with.
    #
    # @return [Dependency] a dependency (not necessary a new instance) that
    #         includes also the version requirements of the given one.
    #
    def merge(other)
      unless name == other.name
        raise ArgumentError, "#{self} and #{other} have different names"
      end
      default   = Requirement.default
      self_req  = requirement
      other_req = other.requirement

      if other_req == default
        dep = self.class.new(name, self_req)
      elsif self_req == default
        dep = self.class.new(name, other_req)
      else
        dep = self.class.new(name, self_req.as_list.concat(other_req.as_list))
      end

      dep
    end

    # Whether the dependency has any pre-release requirements
    #
    # @return [Bool] Whether the dependency has any pre-release requirements
    #
    def prerelease?
      @prerelease ||= requirement.requirements.
        any? { |r| Version.new(r[1].version).prerelease? }
    end

    # Checks whether the dependency would be satisfied by the specification
    # with the given name and version.
    #
    # @param  [String]
    #         The proposed name.
    #
    # @param  [String, Version] version
    #         The proposed version.
    #
    # @return [Bool] Whether the dependency is satisfied.
    #
    def match?(name, version)
      return false unless self.name == name
      return true if requirement.none?
      requirement.satisfied_by?(Version.new(version))
    end

    #-------------------------------------------------------------------------#

    # !@group String representation

    # Creates a string representation of the dependency suitable for
    # serialization and de-serialization without loss of information. The
    # string is also suitable for UI.
    #
    # @note     This representation is used by the {Lockfile}.
    #
    # @example  Output examples
    #
    #           "rails"
    #           "rails (= 1.0)"
    #           "rails (~> 1.0.1)"
    #           "rails (> 1.0, < 2.0)"
    #           "rails (defined in Brickfile)"
    #
    # @return   [String] the representation of the dependency.
    #
    def to_s
      version = ''
      if requirement != Requirement.default
        version << requirement.to_s
      end
      result = @name.dup
      result << " (#{version})" unless version.empty?
      result
    end

    # Generates a dependency from its string representation.
    #
    # @param    [String] string
    #           The string that describes the dependency generated from
    #           {#to_s}.
    #
    # @return   [Dependency] the dependency described by the string.
    #
    def self.from_string(string)
      match_data = string.match(/((?:\s?[^\s(])+)( (?:.*))?/)
      name = match_data[1]
      version = match_data[2]
      version = version.gsub(/[()]/, '') if version
      case version
      when nil, /from `(.*)(`|')/
        Dependency.new(name)
      else
        version_requirements =  version.split(',') if version
        Dependency.new(name, version_requirements)
      end
    end

    # @return [String] a string representation suitable for debugging.
    #
    def inspect
      "<#{self.class} name=#{name} requirements=#{requirement} "
    end

    #--------------------------------------#
  end
end