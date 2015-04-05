# encoding: utf-8

require 'brick/command/spec/create'

module Brick
  class Command
    class Spec < Command
      self.abstract_command = true
      self.summary = 'Manage brick specs'
    end
  end
end