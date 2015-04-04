require 'brick/specification/set'

module Brick
  class Specification

    def self.from_brickspec(pathname)
      spec = eval(File.read(pathname), nil, pathname.to_s)
      spec.defined_in_file = pathname
      spec
    end

    attr_accessor :defined_in_file

    def initialize
      @dependencies = []
      yield self if block_given?
    end

    # Attributes

    attr_accessor :name
    attr_accessor :homepage
    attr_accessor :description
    attr_accessor :source

    attr_reader :version
    def version=(version)
      @version = Brick::Version.new(version)
    end

    def authors=(*names_and_email_addresses)
      list = names_and_email_addresses.flatten
      unless list.first.is_a?(Hash)
        authors = list.last.is_a?(Hash) ? list.pop : {}
        list.each { |name| authors[name] = nil }
      end
      @authors = authors || list.first
    end
    alias_method :author=, :authors=
    attr_reader :authors

    def summary=(summary)
      @summary = summary
      @description ||= summary
    end
    attr_reader :summary

    def part_of=(*name_and_version_requirements)
      self.part_of_dependency = *name_and_version_requirements
      @part_of.only_part_of_other_brick = true
    end
    attr_reader :part_of

    def part_of_dependency=(*name_and_version_requirements)
      @part_of = dependency(*name_and_version_requirements)
    end

    def source_files=(*patterns)
      @source_files = patterns.flatten.map { |p| Pathname.new(p) }
    end
    attr_reader :source_files

    def dependency(*name_and_version_requirements)
      name, *version_requirements = name_and_version_requirements.flatten
      dep = Dependency.new(name, *version_requirements)
      @dependencies << dep
      dep
    end
    attr_reader :dependencies

    attr_accessor :platform

    # Not attributes

    include Config::Mixin

    def any_platform?
      @platform.nil?
    end

     def ==(other)
       self.class === other &&
         @name && @name == other.name &&
           @version && @version == other.version
     end

    def dependency_by_name(name)
      @dependencies.find { |d| d.name == name }
    end

    def part_of_specification_set
      if @part_of
        Set.by_specification_name(@part_of.name)
      end
    end

    # Returns the specification for the brick that this brick's source is a part of.
    def part_of_specification
      (set = part_of_specification_set) && set.specification
    end

    def to_s
      "`#{@name}' version `#{@version}'"
    end

    def inspect
      "#<#{self.class.name} for #{to_s}>"
    end

    def validate!
      missing = []
      missing << "`name'"                       unless @name
      missing << "`version'"                    unless @version
      missing << "`summary'"                    unless @summary
      missing << "`homepage'"                   unless @homepage
      missing << "`author(s)'"                  unless @authors

      incorrect = []
      allowed = [nil, :jruby, :ree, :rbx]
      incorrect << ["`platform'", allowed] unless allowed.include?(@platform)

      unless missing.empty? && incorrect.empty?
        message = "The following #{(missing + incorrect).size == 1 ? 'attribute is' : 'attributes are'}:\n"
        message << "* missing: #{missing.join(", ")}" unless missing.empty?
        message << "* incorrect: #{incorrect.map { |x| "#{x[0]} (#{x[1..-1]})" }.join(", ")}" unless incorrect.empty?
        raise Informative, message
      end
    end

  end
end