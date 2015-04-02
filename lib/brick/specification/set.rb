module Brick
  class Specification
    class Set
      def initialize(brick_dir)
        @brick_dir = brick_dir
      end

      #def add_dependency(dependency)
      #  @dependency = dependency
      #end

      def name
        @brick_dir.basename.to_s
      end

      def spec_pathname
        @brick_dir + required_version.to_s + "#{name}.brickspec"
      end

      def brickspec
        Specification.from_brickspec(spec_pathname)
      end

      # Return the first version that matches the current dependency.
      #def required_version
      #  unless v = versions.find { |v| @dependency.match?(name, v) }
      #    raise "Required version (#{@dependency}) not found for `#{name}'."
      #  end
      #  v
      #end

      #def to_s
      #  "#<#{self.class.name} for `#{name}' with required version `#{required_version}'>"
      #end
      #alias_method :inspect, :to_s

      private

      # Returns Brick::Version instances, for each version directory, sorted from
      # lowest version to highest.
      #def versions
      #  @brick_dir.children.map { |v| Version.new(v.basename) }.sort
      #end
    end
  end
end