require 'rubygems'
require 'bacon'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'lib').to_s)
require 'brick'

$:.unshift((ROOT + 'spec').to_s)
require 'spec_helper/fixture'

context_class = defined?(BaconContext) ? BaconContext : Bacon::Context
context_class.class_eval do
  include Brick::Config::Mixin

  include SpecHelper::Fixture

  def argv(*argv)
    Brick::Command::ARGV.new(argv)
  end
end

config = Brick::Config.instance
config.silent = true

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