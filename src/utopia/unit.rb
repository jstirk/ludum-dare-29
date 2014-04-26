module Utopia
  class Unit

    attr_reader :pos
    attr_accessor :work, :home

    def initialize(world, pos)
      @world = world
      self.pos = pos
    end

    def pos=(pos)
      @world.map[@pos].units -= [self] unless @pos.nil?
      @world.map[pos].units += [self]
      @pos = pos
    end

    def update(delta)
      if @world.hour >= 8 && @world.hour < 17 then
        self.pos = @work.pos
      else
        self.pos = @home.pos
      end
    end

  end
end
