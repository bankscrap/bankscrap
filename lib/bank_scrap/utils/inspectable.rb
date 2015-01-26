module BankScrap
  module Utils
    module Inspectable
      def inspect
        attributes = inspect_attributes.reject { |x|
          begin
            attribute = send x
            !attribute || (attribute.respond_to?(:empty?) && attribute.empty?)
          rescue NoMethodError
            true
          end
        }.map { |attribute|
          "#{attribute.to_s}: #{send(attribute).inspect}"
        }.join ' '
        "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{attributes}>"
      end
    end
  end
end
