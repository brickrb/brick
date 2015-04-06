require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Config do
    describe 'In general' do
      before do
        @original_config = config
        Config.instance = nil
      end

      after do
        Config.instance = @original_config
      end

      it "returns the singleton config instance" do
        config.should.be.instance_of Config
      end

      it "returns the path to the spec-repos dir" do
        config.repos_dir.should == Pathname.new("~/.bricks").expand_path
      end
    end

    describe "concerning a user's project, which is expected in the current working directory" do
      before do
        @original_config = config
        Config.instance = nil
      end

      after do
        Config.instance = @original_config
      end

      it "returns the path to the project root" do
        config.project_root.should == Pathname.pwd
      end

      it "returns the path to the project Brickfile" do
        config.project_brickfile.should == Pathname.pwd + 'Brickfile'
      end
    end

    describe "config with default settings" do
      before do
        @original_config = config
        Config.instance = nil
      end

      after do
        Config.instance = @original_config
      end

      it "is not silent" do
        config.silent.should == false
      end

      it "is not verbose" do
        config.verbose.should == false
      end
    end

    describe "Private helpers" do
      it "returns the path of the user settings file" do
        config.user_settings_file.should == Pathname.new("~/.bricks/config.yaml").expand_path
      end
    end
  end
end