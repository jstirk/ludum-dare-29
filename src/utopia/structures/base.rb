module Utopia
  module Structures
    class Base

      attr_accessor :cell

      def initialize
        @cell = nil
      end

      def width
        1
      end

      def height
        1
      end

      def pos
        @cell.pos
      end

      def update(delta)
      end

    end
  end
end
