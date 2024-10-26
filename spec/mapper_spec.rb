require 'spec_helper'
require_relative '../mapper'  # Adjust the path if necessary

RSpec.describe Mapper do
  describe '.call' do
    class Comment < Mapper
      map 'id',         to: :social_id
      map 'post_id',    to: :post_id
      map %w[owner id], to: :profile_social_id
      map 'text',       to: :body
      map 'created_at', to: :published_at, use: ->(val) { Time.at(val) if val }
    end

    let(:input_data) do
      {
        'id' => '12345',
        'post_id' => '67890',
        'owner' => { 'id' => '98765' },
        'text' => 'This is a comment',
        'created_at' => 1620000000
      }
    end

    it 'maps the input data correctly' do
      result = Comment.call(input_data)

      expect(result).to eq({
        social_id: '12345',
        post_id: '67890',
        profile_social_id: '98765',
        body: 'This is a comment',
        published_at: Time.at(1620000000)
      })
    end

    it 'handles missing optional fields' do
      input_data_without_optional = input_data.except('created_at')
      result = Comment.call(input_data_without_optional)

      expect(result).to eq({
        social_id: '12345',
        post_id: '67890',
        profile_social_id: '98765',
        body: 'This is a comment',
        published_at: nil
      })
    end
  end

  describe '.map' do
    # Add tests for the map method
  end

  # Add more describe blocks for other methods as needed
end
