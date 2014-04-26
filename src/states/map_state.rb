java_import org.newdawn.slick.state.BasicGameState
java_import org.newdawn.slick.Color
java_import org.newdawn.slick.PackedSpriteSheet
java_import org.newdawn.slick.fills.GradientFill
java_import org.newdawn.slick.geom.Rectangle

module Utopia
  class MapState < BasicGameState

    TILE_SIZE = 32

    def getID
      1
    end

    def render(container, game, graphics)
      @tiles_x ||= @screen_x / TILE_SIZE
      @tiles_y ||= @screen_y / TILE_SIZE

      (-@tiles_x/2).upto(@tiles_x/2) do |dx|
        (-@tiles_y/2).upto(@tiles_y/2) do |dy|
          x = @x + dx
          y = @y + dy

          vx = (@screen_x / 2) + (dx * TILE_SIZE)
          vy = (@screen_y / 2) + (dy * TILE_SIZE)

          cell = @map.cell([x,y])

          if cell then
            if cell.structure then
              graphics.set_color(@struct_color)
            else
              graphics.set_color(@empty_color)
            end
            graphics.fill_rect(vx,vy,TILE_SIZE, TILE_SIZE)
          end
        end
      end

      graphics.draw_string("(ESC to exit)", 8, container.height - 30)
    end

    def init(container, game)
      @game = game
      @ui_handler = game.ui_handler
      @world = game.world
      @map = @world.map

      @screen_x = container.width
      @screen_y = container.height

      @empty_color = Color.new(27,38,50,255)
      @struct_color = Color.new(157,157,157,255)

      @x = @world.map.width / 2
      @y = @world.map.height / 2
    end

    def update(container, game, delta)
      input = container.get_input
      container.exit if input.is_key_down(Input::KEY_ESCAPE)

      @ui_handler.update(container, delta)
      @world.update(container, delta)
    end

    def mouseClicked(button, x, y, count)
    end

  private

  end
end
