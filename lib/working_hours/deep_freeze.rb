module WorkingHours
  module DeepFreeze
    refine Array do
      def deep_freeze
        frozen = self.dup.each do |key, value|
          if value.respond_to?(:deep_freeze)
            value.deep_freeze
          else
            value.freeze
          end
        end
        self.replace(frozen)
        self.freeze
      end
    end

    refine Hash do
      def deep_freeze
        frozen = self.dup.each do |key, value|
          if value.respond_to?(:deep_freeze)
            value.deep_freeze
          else
            value.freeze
          end
        end
        self.replace(frozen)
        self.freeze
      end
    end
  end
end