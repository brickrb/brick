require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Command::Init do
    it 'complains if wrong parameters' do
      lambda { run_command('too', 'many') }.should.raise CLAide::Help
    end

    it 'complains if a Brickfile already exists' do
      Dir.chdir(temporary_directory) do
        (Pathname.pwd + 'Brickfile').open('w') { |f| f << "brick 'rails'" }
        lambda { run_command('init') }.should.raise Informative
      end
    end

    it 'creates a Brickfile for a project in current directory' do
      Dir.chdir(temporary_directory) do
        `rm Brickfile`
        run_command('init')
        Pathname.new(temporary_directory + 'Brickfile').exist?.should == true
      end
    end
  end
end