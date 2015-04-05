module Brick
  class Command
    class Init < Command
      self.summary = 'Generate a Brickfile for the current directory.'
      self.description = <<-DESC
        Creates a Brickfile for the current directory if none currently exists.
      DESC

      def initialize(argv)
        @brickfile_path = Pathname.pwd + 'Brickfile'
        super
      end

      def validate!
        super
        raise Informative, 'Existing Brickfile found in directory' unless config.brickfile_path_in_dir(Pathname.pwd).nil?
      end

      def run
        @brickfile_path.open('w') { |f| f << brickfile_template }
      end

      private

      def brickfile_template
        brickfile = ''
        brickfile << <<-PLATFORM.strip_heredoc
          # Uncomment this line to define a global platform for your project
          # platform :jruby, '1.7.19'
        PLATFORM

        brickfile << "\n"
      end

      def template_contents(path)
        if path.exist?
          path.read.chomp.lines.map { |line| "  #{line}" }.join("\n")
        else
          ''
        end
      end
    end
  end
end