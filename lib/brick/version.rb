module Brick
  class Version

    include Comparable

    VERSION_PATTERN = '[0-9]+(\.[0-9a-zA-Z\-]+)*'
    ANCHORED_VERSION_PATTERN = /\A\s*(#{VERSION_PATTERN})*\s*\z/

    def version
      @version.dup
    end
    alias_method :to_s, :version

    # @return [Bool] Whether a string representation is correct.
    #
    def self.correct?(version)
      version.to_s =~ ANCHORED_VERSION_PATTERN
    end

    def self.create(input)
      if self === input then # check yourself before you wreck yourself
        input
      elsif input.nil? then
        nil
      else
        new input
      end
    end

    @@all = {}

    def self.new(version)
      return super unless Brick::Version == self

      @@all[version] ||= super
    end

    # @param  [String,Version] version
    #         A string representing a version, or another version.
    #
    def initialize(version)
      if version.is_a?(Version)
        version = version.version
      end

      raise ArgumentError, "Malformed version number string #{version}" unless
        self.class.correct?(version)

      @version = version.to_s.strip
      @segments = nil
    end

    ##
    # Return a new version object where the next to the last revision
    # number is one greater (e.g., 5.3.1 => 5.4).
    #
    # Pre-release (alpha) parts, e.g, 5.3.1.b.2 => 5.4, are ignored.

    def bump
      segments = self.segments.dup
      segments.pop while segments.any? { |s| String === s }
      segments.pop if segments.size > 1

      segments[-1] = segments[-1].succ
      self.class.new segments.join(".")
    end

    # An instance that represents version 0.
    #
    ZERO = new('0')

    ##
    # A Version is only eql? to another version if it's specified to the
    # same precision. Version "1.0" is not the same as version "1".

    def eql?(other)
      self.class === other and @version == other.version
    end

    # @return [String] a string representation suitable for debugging.
    #
    def inspect
      "<#{self.class} version=#{version}>"
    end

    # @return [Boolean] indicates whether or not the version is a prerelease.
    #
    # @note   Prerelease Bricks can contain a hyphen and/or a letter
    #
    #         For more info, see: http://semver.org
    #
    def prerelease?
      @prerelease ||= @version =~ /[a-zA-Z\-]/
    end

    def release
      return self unless prerelease?

      segments = self.segments.dup
      segments.pop while segments.any? { |s| String === s }
      self.class.new segments.join('.')
    end

    def segments
      @segments ||= @version.scan(/[0-9]+|[a-z]+/i).map do |s|
        /^\d+$/ =~ s ? s.to_i : s
      end
    end

    ##
    # A recommended version for use with a ~> Requirement.
    def approximate_recommendation
      segments = self.segments.dup

      segments.pop    while segments.any? { |s| String === s }
      segments.pop    while segments.size > 2
      segments.push 0 while segments.size < 2

      "~> #{segments.join(".")}"
    end

    ##
    # Compares this version with +other+ returning -1, 0, or 1 if the
    # other version is larger, the same, or smaller than this
    # one. Attempts to compare to something that's not a
    # <tt>Brick::Version</tt> return +nil+.

    def <=> other
      return unless Brick::Version === other
      return 0 if @version == other.version

      lhsegments = segments
      rhsegments = other.segments

      lhsize = lhsegments.size
      rhsize = rhsegments.size
      limit  = (lhsize > rhsize ? lhsize : rhsize) - 1

      i = 0

      while i <= limit
        lhs, rhs = lhsegments[i] || 0, rhsegments[i] || 0
        i += 1

        next      if lhs == rhs
        return -1 if String  === lhs && Numeric === rhs
        return  1 if Numeric === lhs && String  === rhs

        return lhs <=> rhs
      end

      return 0
    end

    #-------------------------------------------------------------------------#

    # @!group Semantic Versioning

    SEMVER_PATTERN = '[0-9]+(\.[0-9]+(\.[0-9]+(-[0-9A-Za-z\-\.]+)?)?)?'
    ANCHORED_SEMANTIC_VERSION_PATTERN = /\A\s*(#{SEMVER_PATTERN})*\s*\z/

    # @return [Bool] Whether the version conforms to the Semantic Versioning
    #         specification (2.0.0-rc.1).
    #
    #
    def semantic?
      version.to_s =~ ANCHORED_SEMANTIC_VERSION_PATTERN
    end

    # @return [Fixnum] The semver major identifier.
    #
    def major
      segments[0]
    end

    # @return [Fixnum] The semver minor identifier.
    #
    def minor
      segments[1] || 0
    end

    # @return [Fixnum] The semver patch identifier.
    #
    def patch
      segments[2] || 0
    end

    #-------------------------------------------------------------------------#
  end
end