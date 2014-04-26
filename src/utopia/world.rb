require 'utopia/map'
require 'utopia/structures/dock'

module Utopia
  class World
    attr_reader :player, :map
    attr_accessor :ui_handler

    def initialize
      @map = Map.new(20,20)
      @structures = {}

      struct = Structures::Dock.new
      @map.place_structure(struct, [9,9])
    end

    def update(container, delta)
    end
  end
end
