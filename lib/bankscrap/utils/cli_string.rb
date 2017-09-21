require 'unicode/display_width'

module Bankscrap
  module Utils
    class CliString < String
      def ljust(to_length, padstr = ' ')
        self.class.new(self + padding(to_length, padstr))
      end

      def rjust(to_length, padstr = ' ')
        self.class.new(padding(to_length, padstr) + self)
      end

      def truncate(truncate_at)
        if display_width > truncate_at
          self.class.new(self[0..-2]).truncate(truncate_at)
        else
          self.class.new(self)
        end
      end

      private

      def padding(to_length, padstr)
        padstr.to_str * padding_length(to_length)
      end

      def padding_length(to_length)
        [
          0,
          to_length - display_width
        ].max
      end

      def display_width
        Unicode::DisplayWidth.of(self)
      end
    end
  end
end
