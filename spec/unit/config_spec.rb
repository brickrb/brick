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

    describe "concerning default settings" do
      before do
        @original_config = config
        Config.instance = nil
      end

      after do
        Config.instance = @original_config
      end

      it "does not print vebose information" do
        config.verbose.should == false
      end
    end
  end
  end