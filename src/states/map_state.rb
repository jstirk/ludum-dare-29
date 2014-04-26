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

    def normalise_radians(rad)
      ret = rad
      ret -= 2.0 * Math::PI if ret > (2.0 * Math::PI)
      ret += 2.0 * Math::PI if ret < 0.0
      ret
    end

    def render(container, game, graphics)
      vx = @screen_x / 2
      vy = @screen_y / 2

      graphics.set_color(@fov_color)
      minf = normalise_radians(@d - @fov / 2.0)
      maxf = normalise_radians(@d + @fov / 2.0)
      dx = vx + (100 * Math.cos(minf))
      dy = vy - (100 * Math.sin(minf))
      tx = vx + (110 * Math.cos(minf))
      ty = vy - (110 * Math.sin(minf))
      graphics.draw_line(vx,vy,dx,dy)
      graphics.draw_string(sprintf("%.2f", minf), tx, ty)
      dx = vx + (100 * Math.cos(maxf))
      dy = vy - (100 * Math.sin(maxf))
      tx = vx + (110 * Math.cos(maxf))
      ty = vy - (110 * Math.sin(maxf))
      graphics.draw_line(vx,vy,dx,dy)
      graphics.draw_string(sprintf("%.2f", maxf), tx, ty)

      graphics.set_color(@text_color)

      graphics.draw_oval(vx-10,vy-10,20,20)

      dx = vx + (20 * Math.cos(@d))
      dy = vy - (20 * Math.sin(@d))
      graphics.draw_line(vx,vy,dx,dy)

      graphics.draw_rect(vx-200, 5, 400, 30)
      graphics.draw_line(vx, 15, vx, 40)

      # if rd > 2.0 * Math::PI then
      #   rd -= 2.0 * Math::PI
      # elsif rd < 0.0 then
      #   rd += 2.0 * Math::PI
      # end

      deg = 90 - (@d / Math::PI * 180)
      if deg >= 360 then
        deg -= 360
      elsif deg < 0 then
        deg += 360
      end
      graphics.draw_string(sprintf("%d", deg), vx, 10)
      # low = ((deg - 50) / 10.0).floor * 10
      # high = ((deg + 50) / 10.0).floor * 10

      low_fov = @d - @fov / 2.0
      high_fov = @d + @fov / 2.0
      lowx = @draw_dist * Math.sin(low_fov)
      lowy = @draw_dist * Math.cos(low_fov)
      highx = @draw_dist * Math.sin(high_fov)
      highy = @draw_dist * Math.cos(high_fov)

      if lowx > highx then
        holdx = lowx
        lowx = highx
        highx = holdx
        holdy = lowy
        lowy = highy
        highy = holdy
      end

      # xmin = [ @x, lowx, highx ].min
      # xmax = [ @x, lowx, highx ].max
      # ymin = [ @y, lowy, highy ].min
      # ymax = [ @y, lowy, highy ].max

      @objects.each do |obj|
        # Is this object visible?
        # if theta_x >= low_fov && theta_x <= high_fov then
          # puts "VISIBLE: #{obj.inspect}"

          p1 = project(obj[:x], obj[:y], 0, vx, vy)
          p2 = project(obj[:x], obj[:y], obj[:h], vx, vy)

          # next if p2[1] > p1[1]

          # next if p2[0] < 0 || p2[0] > @screen_x || p2[1] < 0 || p2[1] > @screen_y

          bearing = p2[2]

          graphics.set_color(obj[:c])

          gx = vx + ((obj[:x] - @x) * TILE_SIZE)
          gy = vy + ((obj[:y] - @y) * TILE_SIZE)
          graphics.draw_oval(gx-4,gy-4,8,8)

          graphics.draw_rect(p2[0]-2,p2[1]-2,4,4)
          graphics.draw_line(p1[0], p1[1], p2[0], p2[1])

          graphics.draw_string(sprintf("%.3f", p2[2]), p2[0], p2[1]-10)

        # end
      end

      graphics.set_color(@text_color)

      graphics.draw_string(sprintf("vis: %.2f,%.2f to %.2f,%.2f", lowx, lowy, highx, highy), 8, container.height - 40)
      graphics.draw_string(sprintf("pos: %.3f,%.3f d: %.3f v: %.3f", @x, @y, @d, @v), 8, container.height - 30)
    end

    def project(x,y,h, vx, vy)
      dx = x - @x
      dy = y - @y
      theta_x = @d + Math.atan(dy / dx)
      # if x < @x then
      #   theta_x += Math::PI
      # end

      px = vx + (@fx * Math.tan(theta_x))

      dh = h.to_f - 1.0

      theta_y = Math.atan(dh / dy.abs)

      py = vy - (@fx * Math.tan(theta_y))

      if dx >= 0.0 then
        # base = (3.0/2.0) * Math::PI # 3PI/2r, 180 deg
        base = 0.0 # 0r, 90 deg
      else
        # base = Math::PI / 2.0 # PI/2r, 0 deg
        base = Math::PI # PIr, 270 deg
      end

      if dy >= 0.0 then
        mult = 1.0
      else
        mult = 1.0
      end

      bearing = normalise_radians(base + (mult * -(theta_x - @d)))

      [px,py, bearing]
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
      @unit_color = Color.new(255,0,0,255)
      @text_color = Color.new(255,255,255,255)
      @fov_color = Color.new(255,255,255,64)

      @x = @world.map.width / 2.0
      @y = @world.map.height / 2.0
      @v = 2.0
      @d = 0.0

      # @fov = 110.0 / 360.0 * (1.0 * Math::PI) # FoV in radians
      @fov = 110.0 * Math::PI / 180.0

      # Calculate the distance from eye to the screen for the given FoV
      @fx = (@screen_x / 2.0) * (Math.tan(@fov / 2.0))

      puts "fx = #{@fx}"

      @objects = [
                    { :x => 9.0, :y => 9.0, :h => 2.0, :c => Color.new(255,0,0,255) },
                    { :x => 11.0, :y => 13.0, :h => 1.0, :c => Color.new(0,255,0,255) },
                    { :x => 10.0, :y => 8.0, :h => 0.5, :c => Color.new(255,255,0,255) },
                    { :x => 12.0, :y => 11.0, :h => 1.0, :c => Color.new(255,0,255,255) },
                    { :x => 12.0, :y => 9.0, :h => 1.0, :c => Color.new(255,255,255,255) }
                 ]

      @draw_dist = 10.0
    end

    def update(container, game, delta)
      input = container.get_input
      container.exit if input.is_key_down(Input::KEY_ESCAPE)

      if input.is_key_down(Input::KEY_EQUALS) then
        @v += delta / 1000.0
        # puts "V: #{@v}"
      end
      if input.is_key_down(Input::KEY_MINUS) then
        @v -= delta / 1000.0
        # puts "V: #{@v}"
      end

      if input.is_key_down(Input::KEY_R) then
        # Reset position
        @x = 10.0
        @y = 10.0
      end
      if input.is_key_down(Input::KEY_W) then
        # TODO: Move forward
        # puts [ @x, @y ].inspect
        @x = @x + (@v * Math.cos(@d) * delta / 1000.0)
        @y = @y - (@v * Math.sin(@d) * delta / 1000.0)
        # puts [ @x, @y ].inspect
      end
      if input.is_key_down(Input::KEY_S) then
        # TODO: Move backwards
        # puts [ @x, @y ].inspect
        @x = @x + (-@v * Math.cos(@d) * delta / 1000.0)
        @y = @y - (-@v * Math.sin(@d) * delta / 1000.0)
        # puts [ @x, @y ].inspect
      end
      if input.is_key_down(Input::KEY_A) then
        # Turn left
        @d += delta / 1000.0 * 2.0
        if @d > (2.0 * Math::PI) then
          @d -= (2.0 * Math::PI)
        end
        # puts "D: #{@d}"
      end
      if input.is_key_down(Input::KEY_D) then
        # Turn right
        @d -= delta / 1000.0 * 2.0
        if @d < 0.0 then
          @d += (2.0 * Math::PI)
        end
        # puts "D: #{@d}"
      end

      @ui_handler.update(container, delta)
      @world.update(container, delta)
    end

    def mouseClicked(button, x, y, count)
    end

  private

  end
end
