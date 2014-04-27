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
      graphics.set_color(@fov_color)
      minf = normalise_radians(@d - @fov / 2.0)
      maxf = normalise_radians(@d + @fov / 2.0)
      dx = @vx + (100 * Math.cos(minf))
      dy = @vy - (100 * Math.sin(minf))
      tx = @vx + (110 * Math.cos(minf))
      ty = @vy - (110 * Math.sin(minf))
      graphics.draw_line(@vx,@vy,dx,dy)
      graphics.draw_string(sprintf("%.2f", minf), tx, ty)
      dx = @vx + (100 * Math.cos(maxf))
      dy = @vy - (100 * Math.sin(maxf))
      tx = @vx + (110 * Math.cos(maxf))
      ty = @vy - (110 * Math.sin(maxf))
      graphics.draw_line(@vx,@vy,dx,dy)
      graphics.draw_string(sprintf("%.2f", maxf), tx, ty)

      graphics.set_color(@text_color)

      graphics.draw_oval(@vx-10,@vy-10,20,20)

      dx = @vx + (20 * Math.cos(@d))
      dy = @vy - (20 * Math.sin(@d))
      graphics.draw_line(@vx,@vy,dx,dy)

      graphics.draw_rect(@vx-200, 5, 400, 30)
      graphics.draw_line(@vx, 15, @vx, 40)

      deg = 90 - (@d / Math::PI * 180)
      if deg >= 360 then
        deg -= 360
      elsif deg < 0 then
        deg += 360
      end
      graphics.draw_string(sprintf("%d", deg), @vx, 10)

      @objects.each do |obj|
        p1 = project(obj[:x], obj[:y], 0)

        bearing = p1[2]
        distance = p1[3]
        visible = in_fov(bearing, minf, maxf)
        if visible then
          obj[:c].a = (@view_distance - distance) / @view_distance
          graphics.set_color(obj[:c])
        else
          graphics.set_color(@fov_color)
        end

        gx = @vx + ((obj[:x] - @x) * TILE_SIZE)
        gy = @vy + ((obj[:y] - @y) * TILE_SIZE)
        graphics.draw_oval(gx-4,gy-4,8,8)

        next unless visible

        case obj[:type]
        when :col
          r = 0.5
          h = obj[:h]
          f1 = project(obj[:x] - r, obj[:y] - r,0)
          f2 = project(obj[:x] + r, obj[:y] - r,0)
          f3 = project(obj[:x] + r, obj[:y] + r,0)
          f4 = project(obj[:x] - r, obj[:y] + r,0)
          graphics.draw_line(f1[0], f1[1], f2[0], f2[1])
          graphics.draw_line(f2[0], f2[1], f3[0], f3[1])
          graphics.draw_line(f3[0], f3[1], f4[0], f4[1])
          graphics.draw_line(f4[0], f4[1], f1[0], f1[1])
          c1 = project(obj[:x] - r, obj[:y] - r,h)
          c2 = project(obj[:x] + r, obj[:y] - r,h)
          c3 = project(obj[:x] + r, obj[:y] + r,h)
          c4 = project(obj[:x] - r, obj[:y] + r,h)
          graphics.draw_line(c1[0], c1[1], c2[0], c2[1])
          graphics.draw_line(c2[0], c2[1], c3[0], c3[1])
          graphics.draw_line(c3[0], c3[1], c4[0], c4[1])
          graphics.draw_line(c4[0], c4[1], c1[0], c1[1])

          graphics.draw_line(f1[0], f1[1], c1[0], c1[1])
          graphics.draw_line(f2[0], f2[1], c2[0], c2[1])
          graphics.draw_line(f3[0], f3[1], c3[0], c3[1])
          graphics.draw_line(c4[0], f4[1], c4[0], c4[1])
        else
          r = obj[:r] || 0.5
          v1 = project(obj[:x] - r, obj[:y] - r,0)
          v2 = project(obj[:x] + r, obj[:y] - r,0)
          v3 = project(obj[:x] + r, obj[:y] + r,0)
          v4 = project(obj[:x] - r, obj[:y] + r,0)

          graphics.draw_line(v1[0], v1[1], v2[0], v2[1])
          graphics.draw_line(v2[0], v2[1], v3[0], v3[1])
          graphics.draw_line(v3[0], v3[1], v4[0], v4[1])
          graphics.draw_line(v4[0], v4[1], v1[0], v1[1])

          if obj[:h] then
            p2 = project(obj[:x], obj[:y], obj[:h])

            # graphics.draw_rect(p2[0]-2,p2[1]-2,4,4)
            graphics.draw_line(p1[0], p1[1], p2[0], p2[1])
            graphics.draw_string(sprintf("%.2fm @ %.3f", distance, bearing), p2[0], p2[1]-10)
          end
        end
      end

      graphics.set_color(@text_color)

      graphics.draw_string(sprintf("pos: %.3f,%.3f d: %.3f v: %.3f", @x, @y, @d, @v), 8, container.height - 30)
    end

    def in_fov(bearing, f1, f2)
      min = [ f1, f2 ].min
      max = [ f1, f2 ].max
      if (f1 - f2).abs < Math::PI then
        # Cohesive segment - simple test
        (bearing > min && bearing < max)
      else
        # Split about 0 - test two sectors
        (bearing < min) || (bearing > max)
      end
    end

    def project(x,y,h)
      dx = x - @x
      dy = y - @y
      theta_x = @d + Math.atan(dy / dx)

      distance = Math.sqrt((dx ** 2) + (dy ** 2))

      px = @vx + (@fx * Math.tan(theta_x))

      dh = h.to_f - 1.0

      theta_y = Math.atan(dh / distance)

      py = @vy - (@fx * Math.tan(theta_y))

      if dx >= 0.0 then
        base = 0.0 # 0r, 90 deg
      else
        base = Math::PI # PIr, 270 deg
      end

      if dy >= 0.0 then
        mult = 1.0
      else
        mult = 1.0
      end

      bearing = normalise_radians(base + (mult * -(theta_x - @d)))

      [px,py, bearing, distance]
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
      @view_distance = 3.0

      # @fov = 110.0 / 360.0 * (1.0 * Math::PI) # FoV in radians
      @fov = 90.0 * Math::PI / 180.0

      # Calculate the distance from eye to the screen for the given FoV
      @fx = (@screen_x / 2.0) / (Math.tan(@fov / 2.0))

      puts "fx = #{@fx}"

      @objects = [
                    { :x => 9.0, :y => 9.0, :h => 5.0, :c => Color.new(255,0,0,255), :type => :col },
                    { :x => 11.0, :y => 13.0, :h => 1.0, :c => Color.new(0,255,0,255) },
                    { :x => 10.0, :y => 8.0, :h => 0.5, :c => Color.new(255,255,0,255) },
                    { :x => 12.0, :y => 11.0, :h => 1.0, :c => Color.new(255,0,255,255) },
                    { :x => 12.0, :y => 9.0, :h => 1.0, :c => Color.new(255,255,255,255) },
                    { :x => 9.0, :y => 7.0, :c => Color.new(0,0,255,255), :r => 0.5, :type => :pool },
                    { :x => 0.0, :y => 0.0, :c => Color.new(255,255,0,255), :r => 0.5, :type => :col, :h => 4.0 },
                 ]


      @sounds = [
                    # { :x => 10.0, :y => 10.0, :sample => :sinister, :r => 8.0, :t => 2000.0 },
                    { :x => 0.0, :y => 0.0, :sample => :drip2, :r => 10.0, :rand => 0.001, :t => 1000.0 },
                    { :x => 9.0, :y => 7.0, :sample => :drip, :r => 10.0, :rand => 0.002, :t => 1000.0 },
      ]

      @playing = {}

      @draw_dist = 10.0

      @vx = @screen_x / 2
      @vy = @screen_y / 2
    end

    def update(container, game, delta)
      input = container.get_input
      container.exit if input.is_key_down(Input::KEY_ESCAPE)

      if input.is_key_down(Input::KEY_EQUALS) then
        @v += delta / 1000.0
      end
      if input.is_key_down(Input::KEY_MINUS) then
        @v -= delta / 1000.0
      end

      if input.is_key_down(Input::KEY_R) then
        # Reset position
        @x = 10.0
        @y = 10.0
      end
      if input.is_key_down(Input::KEY_W) || input.is_key_down(Input::KEY_UP) then
        # Move forward
        @x = @x + (@v * Math.cos(@d) * delta / 1000.0)
        @y = @y - (@v * Math.sin(@d) * delta / 1000.0)
        @ui_handler.sound.play(:step, 0.2, 0)
      end
      if input.is_key_down(Input::KEY_S) || input.is_key_down(Input::KEY_DOWN) then
        # Move backwards
        @x = @x + (-@v * Math.cos(@d) * delta / 1000.0)
        @y = @y - (-@v * Math.sin(@d) * delta / 1000.0)
        @ui_handler.sound.play(:step, 0.2, 0)
      end
      if input.is_key_down(Input::KEY_A) || input.is_key_down(Input::KEY_LEFT) then
        # Turn left
        @d += delta / 1000.0 * 2.0
        if @d > (2.0 * Math::PI) then
          @d -= (2.0 * Math::PI)
        end
      end
      if input.is_key_down(Input::KEY_D) || input.is_key_down(Input::KEY_RIGHT) then
        # Turn right
        @d -= delta / 1000.0 * 2.0
        if @d < 0.0 then
          @d += (2.0 * Math::PI)
        end
      end

      @sounds.each do |sound|
        p1 = project(sound[:x], sound[:y], 0)

        d = p1[3]

        if d <= sound[:r] then
          if sound[:timer].to_f <= 0.0 then
            if Kernel::rand <= (sound[:rand] || 1.0) then

              # stheta = Math.atan(sdx / sdy)
              # srx = Math.sin(stheta)
              # sry = Math.cos(stheta)

              # x1 = sdy / Math.tan(@d)
              # h = sdy / Math.sin(@d)
              # alpha = Math.atan((sdx - x1) / h)
              # beta = @d - alpha

              srx = 1.0

              sbearing = p1[2]
              db = @d - sbearing
              srx = Math.sin(db)

              sound[:timer] = sound[:t]
              i = (sound[:r] - d) / sound[:r]
              @ui_handler.sound.play(sound[:sample], (sound[:vol] || 1.0) * i, srx)
            end
          else
            sound[:timer] -= delta
          end
        end

      end

      @ui_handler.update(container, delta)
      @world.update(container, delta)
    end

    def mouseClicked(button, x, y, count)
    end

  private

  end
end
