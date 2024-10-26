# frozen_string_literal: true

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

# class Comment < Mapper
#   map 'id',         to: :social_id
#   map 'post_id',    to: :post_id
#   map %w[owner id], to: :profile_social_id

#   map 'text', to: :body

#   map 'created_at', to: :published_at, use: ->(val) { Time.at(val) if val }
# end

# class Profile < Mapper
#   map 'id',        to: :social_id
#   map 'biography', to: :description, optional: true
#   map 'username',  to: :username

#   map 'profile_pic_url', to: :avatar_url

#   map 'full_name', to: :first_name, use: ->(val) { val.split[0] if val.split.size == 2 }, optional: true
#   map 'full_name', to: :last_name,  use: ->(val) { val.split[1] if val.split.size == 2 }, optional: true

#   map %w[edge_followed_by count], to: :followers
#   map %w[edge_follow count],      to: :following
# end
