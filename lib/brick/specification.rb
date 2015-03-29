module Brick
  def self._eval_brickspec(path)
    eval(path.read, nil, path.to_s)
  end

  class Specification

    def self.from_brickspec(path)
      spec = Brick._eval_brickspec(path)
      spec.defined_in_file = path
      spec
    end

    def initialize
      @dependencies = []
      yield self if block_given?
    end

    ## Attributes

    attr_accessor :name
    attr_accessor :homepage
    attr_accessor :description

    attr_reader :version
    def version=(version)
      @version = version #Version.new(version)
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

    def dependency(*name_and_version_requirements)
      name, *version_requirements = name_and_version_requirements.flatten
      #dep = Dependency.new(name, *version_requirements)
      #@dependencies << dep
      #dep
    end
    attr_reader :dependencies

    attr_accessor :platform

    ## Not Attributes

    include Config::Mixin

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

    def any_platform?
      @platform.nil?
    end

    def to_s
      "`#{@name}' version `#{@version}'"
      end
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

      unless missing.empty? && incorrect.empty?
        message = "The following #{(missing + incorrect).size == 1 ? 'attribute is' : 'attributes are'}:\n"
        message << "* missing: #{missing.join(", ")}" unless missing.empty?
        message << "* incorrect: #{incorrect.map { |x| "#{x[0]} (#{x[1..-1]})" }.join(", ")}" unless incorrect.empty?
        raise Informative, message
      end
    end

  end
end