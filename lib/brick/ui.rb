module Brick
  module UI
    def self.puts(message)
      STDOUT.puts message
    end

    def self.warn(message)
      STDERR.puts message
    end

  end
end