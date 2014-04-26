module Utopia
  class Cell

    attr_reader :pos
    attr_accessor :structure

    def initialize(pos)
      @pos = pos
      @structure = nil
    end

  end
end
