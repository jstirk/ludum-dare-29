$:.push File.expand_path('../../lib', __FILE__)
$:.push File.expand_path('../', __FILE__)

require 'java'
require 'lwjgl.jar'
require 'slick.jar'

java_import org.newdawn.slick.state.StateBasedGame
java_import org.newdawn.slick.GameContainer
java_import org.newdawn.slick.Graphics
java_import org.newdawn.slick.Image
java_import org.newdawn.slick.Input
java_import org.newdawn.slick.SlickException
java_import org.newdawn.slick.AppGameContainer

require 'states/map_state'
require 'utopia/world'
require 'utopia/ui/handler'

module Utopia
  class Game < StateBasedGame

    attr_reader :world, :ui_handler

    def initialize(name)
      @ui_handler = UI::Handler.new

      @world = World.new
      @world.ui_handler = @ui_handler

      super
    end

    def player
      @world.player
    end

    def initStatesList(container)
      self.add_state(MapState.new)
    end
  end
end

# WIDTH = 1280
# HEIGHT = 720
# FULLSCREEN = true

WIDTH = 1000
HEIGHT = 700
FULLSCREEN = false

app = AppGameContainer.new(Utopia::Game.new('Utopia'))
app.set_display_mode(WIDTH, HEIGHT, FULLSCREEN)
app.start
