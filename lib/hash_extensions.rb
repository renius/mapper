# frozen_string_literal: true

class Hash
  def fetch_nested(*keys)
    val = fetch(keys.shift)
    return val if keys.empty?

    val.fetch_nested(*keys)
  end
end
