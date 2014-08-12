module WorkingHours
  module DeepFreeze
    def deep_freeze object
      if object.is_a? Array
        object.replace(object.dup.each { |_, value| deep_freeze(value) })
      elsif object.is_a? Hash
        object.replace(object.dup.each { |_, value| deep_freeze(value) })
      end
      object.freeze
    end
  end
end