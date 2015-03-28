# encoding: utf-8

# The mods of interest are {Brick::CLAide::ARGV}, {Brick::CLAide::Command}, and
# {Brick::CLAide::InformativeError}
#
module Brick::CLAide
  # @return [String]
  #
  #   Brick::CLAide’s version, following [semver](http://semver.org).
  #
  VERSION = '0.8.1'

  require 'brick/vendor/claide/lib/claide/ansi'
  require 'brick/vendor/claide/lib/claide/argument'
  require 'brick/vendor/claide/lib/claide/argv'
  require 'brick/vendor/claide/lib/claide/command'
  require 'brick/vendor/claide/lib/claide/help'
  require 'brick/vendor/claide/lib/claide/informative_error'
end
