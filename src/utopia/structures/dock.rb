module Utopia
  module Structures
    class Dock

      attr_accessor :cell

      def initialize
        @cell = nil
      end

      def width
        3
      end

      def height
        3
      end

      def pos
        @cell.pos
      end

    end
  end
end
