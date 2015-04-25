require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Lockfile do
    describe "A Brick::Lockfile, in general" do
      it "loads from a file" do
        lockfile = Lockfile.from_file(fixture('Brickfile.lock'))
        lockfile.defined_in_file.should == fixture('Brickfile.lock')
      end
    end

  end
end