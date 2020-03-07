require "active_graph"
require "active_graph/translations/version"
require "active_support"

module ActiveGraph
  module Translations
    extend ActiveSupport::Concern

    # Error enumeration
    class Error < StandardError; end

    included do
      class << self
        attr_reader :translated_fields

        def translates(*translated_fields)
          @translated_fields = translated_fields.map(&:to_s)
        end
      end

      attr_reader :translation_cache

      def initialize(*args)
        @translation_cache ||= {}
        super(*args)
      end

      def method_missing(name, *args)
        assignment = name.to_s[0, -1] == "="
        string_name = name.to_s[0, name.to_s.length - 1]

        if translated_fields.include? string_name
          if assignment
            assign_translation name, *args
          else
            retrieve_translation name
          end
        else
          super(name, *args)
        end
      end

      private

        def translated_fields
          self.class.translated_fields
        end

        def assign_translation(name, *args)
          query = <<-CYPHER
            MATCH (n:%{label} { uuid: '%{id}' })
            MERGE (n)<-[:translation { field: '%{field}' }]-(t:Translation)
            SET t.#{I18n.locale} = '%{value}'
            RETURN t as translation
          CYPHER

          query = query % {
            field: field,
            id: id,
            label: self.class.to_s,
            value: args.first,
          }

          translation_cache[name] = ActiveGraph::ActiveBase
            .current_session
            .query(query)
            .translation
            .public_send(I18n.locale)
        end

        def retrieve_translation(name)
          query = <<-CYPHER
            MATCH (n:%{label} { uuid: '%{id}' })
                  <-[r:translation { field: '%{field}' }]-
                  (t:Translation)
            RETURN t as translation
          CYPHER

          query = query % {
            id: id,
            label: self.class.to_s,
            field: name,
          }

          translation_cache[name] ||= ActiveGraph::ActiveBase
            .current_session
            .query(query)
            .translation
            .public_send(I18n.locale)
        end
    end
  end
end
