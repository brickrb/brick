module Brick
  class Lockfile
    def self.from_file(path)
      lockfile = Lockfile.new do
        eval(path.read, nil, path.to_s)
      end
      lockfile.defined_in_file = path
      lockfile
    end

    def lockfile?
      true
    end

    attr_accessor :defined_in_file
  end
end