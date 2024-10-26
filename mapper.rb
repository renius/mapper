# frozen_string_literal: true

require_relative 'lib/hash_extensions'

class Mapper
  Options = Data.define(:key, :handler, :optional) do
    def handler?
      handler
    end

    def optional?
      optional
    end
  end

  class << self
    def call(attrs)
      mapping.each_with_object({}) do |(key, options), result|
        value =
          if options.optional?
            attrs.dig(*options.key)
          else
            attrs.fetch_nested(*options.key)
          end

        value = options.handler.call(value) if options.handler?

        result.store(key, value)
        result
      end
    end

    def map(key, to:, use: nil, optional: false)
      mapping.store(
        to,
        Options.new(
          key: key,
          handler: use,
          optional: optional
        )
      )
    end

    def mapping
      @mapping ||= {}
    end
  end
end
