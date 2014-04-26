java_import org.newdawn.slick.PackedSpriteSheet

module Utopia
  module UI
    class Sprites

      def inititalize
        @sheet = PackedSpriteSheet.new("data/utopia.def")
      end
    end
  end
end
