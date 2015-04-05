require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Brickfile do
    describe "A Brick::Brickfile, in general" do
      it "loads from a file" do
        brickfile = Brickfile.from_file(fixture('Brickfile'))
        brickfile.defined_in_file.should == fixture('Brickfile')
      end

      it "assigns the platform attribute" do
        brickfile = Brickfile.new { platform :jruby }
        brickfile.platform.should == :jruby
      end

      it "adds dependencies" do
        brickfile = Brickfile.new { brick 'rails'; brick 'rack', '>= 0.1' }
        brickfile.dependencies.size.should == 2
        brickfile.dependency_by_name('rails').should == Dependency.new('rails')
        brickfile.dependency_by_name('rack').should == Dependency.new('rack', '>= 0.1')
      end
    end

    describe "concerning validations" do
      it "raises if an invalid platform is specified" do
        exception = lambda {
          Brickfile.new { platform :windows }.validate!
        }.should.raise Informative
        exception.message.should.include "platform"
      end

      it "raises if no dependencies were specified" do
        exception = lambda {
          Brickfile.new {}.validate!
        }.should.raise Informative
        exception.message.should.include "dependencies"
      end
    end
  end
end