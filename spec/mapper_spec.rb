require 'spec_helper'
require_relative '../mapper'  # Adjust the path if necessary

RSpec.describe Mapper do
  describe 'Comment example' do
    class Comment < Mapper
      map 'id',         to: :social_id
      map 'post_id',    to: :post_id
      map %w[owner id], to: :profile_social_id
      map 'text',       to: :body
      map 'created_at', to: :published_at, use: ->(val) { Time.at(val) if val }, optional: true
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
  describe 'Profile example' do
    class Profile < Mapper
      map 'id',        to: :social_id
      map 'biography', to: :description, optional: true
      map 'username',  to: :username
      map 'profile_pic_url', to: :avatar_url
      map 'full_name', to: :first_name, use: ->(val) { val.split[0] if val && val.split.size == 2 }, optional: true
      map 'full_name', to: :last_name,  use: ->(val) { val.split[1] if val && val.split.size == 2 }, optional: true
      map %w[edge_followed_by count], to: :followers
      map %w[edge_follow count],      to: :following
    end

    let(:input_data) do
      {
        'id' => '12345',
        'biography' => 'A short bio',
        'username' => 'johndoe',
        'profile_pic_url' => 'https://example.com/avatar.jpg',
        'full_name' => 'John Doe',
        'edge_followed_by' => { 'count' => 1000 },
        'edge_follow' => { 'count' => 500 }
      }
    end

    it 'maps the input data correctly' do
      result = Profile.call(input_data)

      expect(result).to eq({
        social_id: '12345',
        description: 'A short bio',
        username: 'johndoe',
        avatar_url: 'https://example.com/avatar.jpg',
        first_name: 'John',
        last_name: 'Doe',
        followers: 1000,
        following: 500
      })
    end

    it 'handles missing optional fields' do
      input_data_without_optional = input_data.except('biography', 'full_name')
      result = Profile.call(input_data_without_optional)

      expect(result).to eq({
        social_id: '12345',
        description: nil,
        username: 'johndoe',
        avatar_url: 'https://example.com/avatar.jpg',
        first_name: nil,
        last_name: nil,
        followers: 1000,
        following: 500
      })
    end

    it 'handles full_name with only one word' do
      input_data_with_single_name = input_data.merge('full_name' => 'John')
      result = Profile.call(input_data_with_single_name)

      expect(result[:first_name]).to be_nil
      expect(result[:last_name]).to be_nil
    end
  end
end
