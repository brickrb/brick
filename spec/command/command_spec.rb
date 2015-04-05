require File.expand_path('../../spec_helper', __FILE__)

module Brick
  describe Command do
    extend SpecHelper::Command

    it 'displays the current version number with the --version flag' do
      Brick::Command.version.should == VERSION
    end
  end
end