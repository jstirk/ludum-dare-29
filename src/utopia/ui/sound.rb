import org.newdawn.slick.openal.Audio
import org.newdawn.slick.openal.AudioLoader
import org.newdawn.slick.util.ResourceLoader
import org.newdawn.slick.openal.SoundStore

module Utopia
  module UI
    class Sound

      def initialize
        @sounds = {}
        %w( drip drip2 happier sad shudder sinister soft1 step ).each do |sound|
          @sounds[sound.intern] = AudioLoader.getAudio("WAV", ResourceLoader.getResourceAsStream("data/sounds/#{sound}.wav"))
        end

        @vols = Hash.new { |hash, key| hash[key] = 1.0 }
        @vols[:step] = 0.2
        @vols[:drip] = 0.4
        @vols[:drip2] = 0.4

        @duration = {
          :step => 500.0
        }

        @repeat = {
          :step => 0.0
        }
      end

      def update(delta)
        @repeat.each do |k, v|
          @repeat[k] -= delta
        end
      end

      def play(sound, vol, x)
        if @repeat[sound] then
          if @repeat[sound] <= 0.0 then
            @repeat[sound] = @duration[sound]
          else
            return
          end
        end

        @sounds[sound].play_as_sound_effect(1.0, vol * @vols[sound], false, x, 1.0, 0.0) unless @sounds[sound].nil?
      end

    end
  end
end
