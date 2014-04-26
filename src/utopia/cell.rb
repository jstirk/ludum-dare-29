module Utopia
  class Cell

    attr_reader :pos
    attr_accessor :structure
    attr_accessor :units

    def initialize(pos)
      @pos = pos
      @structure = nil
      @units = []
    end

  end
end
