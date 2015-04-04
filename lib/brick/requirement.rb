module Brick
  # A Requirement is a set of one or more version restrictions of a
  # {Dependency}.
  #
  class Requirement
    OPS = { #:nodoc:
      "="  =>  lambda { |v, r| v == r },
      "!=" =>  lambda { |v, r| v != r },
      ">"  =>  lambda { |v, r| v >  r },
      "<"  =>  lambda { |v, r| v <  r },
      ">=" =>  lambda { |v, r| v >= r },
      "<=" =>  lambda { |v, r| v <= r },
      "~>" =>  lambda { |v, r| v >= r && v.release < r.bump }
    }

    quoted_operators = OPS.keys.map { |k| Regexp.quote k }.join '|'

    # @return [Regexp] The regular expression used to validate input strings.
    #
    PATTERN = /\A\s*(#{quoted_operators})?\s*(#{Version::VERSION_PATTERN})\s*\z/

    ##
    # The default requirement matches any version

    DefaultRequirement = [">=", Brick::Version.new(0)]

    ##
    # Raised when a bad requirement is encountered

    class BadRequirementError < ArgumentError; end

    #-------------------------------------------------------------------------#

    # Factory method to create a new requirement.
    #
    # @param  [Requirement, Version, Array<Version>, String, Nil] input
    #         The input used to create the requirement.
    #
    # @return [Requirement] A new requirement.
    #
    def self.create(input)
      case input
      when Requirement
        input
      when Version, Array
        new(input)
      else
        if input.respond_to? :to_str
          new([input.to_str])
        else
          default
        end
      end
    end

    # @return [Requirement] The default requirement.
    #
    def self.default
      new('>= 0')
    end

    # Parses the given object returning a tuple where the first entry is an
    # operator and the second a version. If not operator is provided it
    # defaults to `=`.
    #
    # @param  [String, Version] input
    #         The input passed to create the requirement.
    #
    # @return [Array] A tuple representing the requirement.
    #
    def self.parse(input)
      return ['=', input] if input.is_a?(Version)

      unless PATTERN =~ input.to_s
        raise ArgumentError, "Illformed requirement `#{input.inspect}`"
      end

      operator = Regexp.last_match[1] || '='
      version = Version.new(Regexp.last_match[2])
      [operator, version]
    end

    ##
    # An array of requirement pairs. The first element of the pair is
    # the op, and the second is the Brick::Version.

    attr_reader :requirements #:nodoc:

    ##
    # Constructs a requirement from +requirements+. Requirements can be
    # Strings, Brick::Versions, or Arrays of those. +nil+ and duplicate
    # requirements are ignored. An empty set of +requirements+ is the
    # same as <tt>">= 0"</tt>.

    def initialize *requirements
      requirements = requirements.flatten
      requirements.compact!
      requirements.uniq!

      if requirements.empty?
        @requirements = [DefaultRequirement]
      else
        @requirements = requirements.map! { |r| self.class.parse r }
      end
    end

    ##
    # Concatenates the +new+ requirements onto this requirement.

    def concat new
      new = new.flatten
      new.compact!
      new.uniq!
      new = new.map { |r| self.class.parse r }

      @requirements.concat new
    end

    ##
    # true if this brick has no requirements.

    def none?
      if @requirements.size == 1
        @requirements[0] == DefaultRequirement
      else
        false
      end
    end

    ##
    # true if the requirement is for only an exact version

    def exact?
      return false unless @requirements.size == 1
      @requirements[0][0] == "="
    end

    def as_list # :nodoc:
      requirements.map { |op, version| "#{op} #{version}" }.sort
    end

    def hash # :nodoc:
      requirements.sort.hash
    end

    ##
    # A requirement is a prerelease if any of the versions inside of it
    # are prereleases

    def prerelease?
      requirements.any? { |r| r.last.prerelease? }
    end

    def pretty_print q # :nodoc:
      q.group 1, 'Brick::Requirement.new(', ')' do
        q.pp as_list
      end
    end

    ##
    # True if +version+ satisfies this Requirement.

    def satisfied_by? version
      raise ArgumentError, "Need a Brick::Version: #{version.inspect}" unless
        Brick::Version === version
      # #28965: syck has a bug with unquoted '=' YAML.loading as YAML::DefaultKey
      requirements.all? { |op, rv| (OPS[op] || OPS["="]).call version, rv }
    end

    alias :=== :satisfied_by?
    alias :=~ :satisfied_by?

    ##
    # True if the requirement will not always match the latest version.

    def specific?
      return true if @requirements.length > 1 # GIGO, > 1, > 2 is silly

      not %w[> >=].include? @requirements.first.first # grab the operator
    end

    def to_s # :nodoc:
      as_list.join ", "
    end

    def == other # :nodoc:
      Brick::Requirement === other and to_s == other.to_s
    end

    #-------------------------------------------------------------------------#
  end
end