require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Command::Spec do

    extend SpecHelper::Command

    describe 'In general' do
      it 'complains for wrong parameters' do
        lambda { run_command('spec') }.should.raise CLAide::Help
        lambda { run_command('spec', 'create') }.should.raise CLAide::Help
        lambda { run_command('spec', '--create') }.should.raise CLAide::Help
        lambda { run_command('spec', 'NAME') }.should.raise CLAide::Help
      end
    end

    #-------------------------------------------------------------------------#

    describe 'create subcommand' do
      extend SpecHelper

      it 'creates a new podspec stub file' do
        run_command('spec', 'create', 'Bananas')
        path = temporary_directory + 'Bananas.brickspec'
        spec = Specification.from_brickspec(path)

        spec.name.should         == 'Bananas'
        spec.license.should      == 'MIT (example)'
        spec.version.should      == Version.new('0.0.1')
        spec.summary.should      == 'A short description of Bananas.'
        spec.homepage.should     == 'http://EXAMPLE/Bananas'
        spec.authors.should      == { "John Smith" => "jsmith@google.com" }
      end
    end

    #-------------------------------------------------------------------------#

  end
end