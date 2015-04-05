require 'rubygems'
require 'bacon'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'lib').to_s)
require 'brick'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/command'         # Test Brick::Command CLI commands
require 'spec_helper/fixture'         # Use fixtures in tests

module Bacon
  class Context
    include Brick::Config::Mixin
    include SpecHelper::Fixture
    include SpecHelper::Command

    def temporary_directory
      SpecHelper.temporary_directory
    end
  end
end

config = Brick::Config.instance
config.silent = true

module SpecHelper
  def self.temporary_directory
    ROOT + 'tmp'
  end
end

def fixture_spec(name)
  file = SpecHelper::Fixture.fixture(name)
  Brick::Specification.from_brickspec(file)
end

SpecHelper::Fixture.fixture('banana-lib') # ensure it exists

class Brick::Specification::Set
  def self.reset!
    @sets = nil
  end
end