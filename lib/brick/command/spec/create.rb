module Brick
  class Command
    class Spec < Command
      class Create < Spec
        self.summary = 'Create spec file stub.'

        self.description = <<-DESC
          Creates a BrickSpec, in the current working dir, called `NAME.br'.
          If a GitHub url is passed the spec is prepopulated.
        DESC

        self.arguments = [
          CLAide::Argument.new(%w(NAME https://github.com/USER/REPO), false),
        ]

        def initialize(argv)
          @name_or_url, @url = argv.shift_argument, argv.shift_argument
          super
        end

        def validate!
          super
          help! 'A brick name or repo URL is required.' unless @name_or_url
        end

        def run
          data = default_data_for_template(@name_or_url)
          spec = spec_template(data)
          (Pathname.pwd + "#{data[:name]}.brickspec").open('w') { |f| f << spec }
          UI.puts "\nSpecification created at #{data[:name]}.brickspec" #.green
        end

        private

        #--------------------------------------#

        # Templates information retrieval for spec create
        #

        def default_data_for_template(name)
          data = {}
          data[:name]          = name
          data[:version]       = '0.0.1'
          data[:summary]       = "A short description of #{name}."
          data[:homepage]      = "http://EXAMPLE/#{name}"
          data
        end

        def spec_template(data)
          <<-SPEC
#
#  Be sure to run `brick spec lint #{data[:name]}.brickspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

Brick::Specification.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "#{data[:name]}"
  s.version      = "#{data[:version]}"
  s.summary      = "#{data[:summary]}"

  s.description  = <<-DESC
                   A longer description of #{data[:name]} in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * Brick will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, Brick strips it!
                   DESC

  s.homepage     = "#{data[:homepage]}"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT (example)"


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. Brick also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #

  s.author               = { "John Smith" => "jsmith@google.com" }
  # Or just: s.author    = "John Smith"
  # s.authors            = { "John Smith" => "jsmith@google.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Brick runs only on JRuby, REE, or Rubinius, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :rbx
  # s.platform     = :rbx, "1.0"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If you depend on other Brickspecs you can include multiple dependencies to ensure it works.

  # s.dependency "rack", "~> 1.0"

end
          SPEC
        end
      end
    end
  end
end