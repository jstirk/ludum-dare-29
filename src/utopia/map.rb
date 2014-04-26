require 'utopia/cell'

module Utopia
  class Map

    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height

      @cells = Hash.new { |hash, key| hash[key] = Cell.new(key) }
    end

    def cell(pos)
      if in_range?(pos) then
        @cells[pos]
      end
    end

    def [](pos)
      cell(pos)
    end

    def in_range?(pos)
      x,y=pos
      (x >= 0) && (y >= 0) && (x < width) && (y < width)
    end

    def place_structure(structure, pos)
      x,y=pos
      structure.cell = cell(pos)
      # TODO: Sanity check that all cells are clear and fine to place
      x.upto(x+structure.width) do |cx|
        y.upto(y+structure.height) do |cy|
          cell([cx,cy]).structure = structure
        end
      end
    end

  end
end
