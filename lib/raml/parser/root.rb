require 'raml/root'
require 'raml/parser/resource'
require 'raml/parser/documentation'
require 'raml/parser/util'
require 'raml/errors/unknown_attribute_error'

module Raml
  class Parser
    class Root
      include Raml::Parser::Util

      BASIC_ATTRIBUTES = %w[title base_uri version]
      ATTRIBUTES = BASIC_ATTRIBUTES + %w[traits documentation]

      attr_accessor :traits

      def initialize
        @traits = {}
      end

      def parse(data)
        root = Raml::Root.new
        parse_attributes(root, data)
      end

      private

        def parse_attributes(root, data)
          data.each do |key, value|
            key = underscore(key)
            case key
            when *BASIC_ATTRIBUTES
              root.send("#{key}=".to_sym, parse_value(value))
            when 'traits'
              parse_traits(parse_value(value))
            when 'documentation'
              data = data.is_a?(Array) ? data : [data]
              data.each do |values|
                root.documentations << Raml::Parser::Documentation.new(self).parse(parse_value(value))
              end
            when /^\//
              root.resources << Raml::Parser::Resource.new(root, self).parse(root, key, parse_value(value))
            else
              raise UnknownAttributeError.new "Unknown root key: #{key}"
            end
          end

          root
        end

        def parse_traits(traits)
          traits.each do |name, data|
            @traits[name] = data
          end
        end

    end
  end
end
