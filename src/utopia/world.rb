require 'utopia/map'
require 'utopia/structures/all'
require 'utopia/unit'

module Utopia
  class World
    attr_reader :player, :map
    attr_reader :day, :hour
    attr_accessor :ui_handler

    def initialize
      @map = Map.new(20,20)
      @structures = []

      struct = Structures::Dock.new
      @map.place_structure(struct, [9,9])
      @structures << struct

      struct = Structures::Cantina.new
      @map.place_structure(struct, [9,12])
      @structures << struct

      struct = Structures::Quarters.new
      @map.place_structure(struct, [9,8])
      @structures << struct

      struct = Structures::Quarters.new
      @map.place_structure(struct, [10,8])
      @structures << struct

      struct = Structures::Quarters.new
      @map.place_structure(struct, [11,8])
      @structures << struct

      @units = []
      unit = Unit.new(self, [10,10])
      unit.work = @structures[0]
      unit.home = @structures[2]
      @units << unit

      unit = Unit.new(self, [10,10])
      unit.work = @structures[0]
      unit.home = @structures[3]
      @units << unit

      @day = 0
      @hour = 12

      @ticks = 0.0
    end

    def update(container, delta)
      @ticks += delta
      if @ticks >= 1000.0 then
        @hour += 1
        if @hour >= 24 then
          @hour = 0
          @day += 1
        end
        @ticks = 0.0
      end

      @structures.each { |s| s.update(delta) }
      @units.each { |u| u.update(delta) }
    end
  end
end
