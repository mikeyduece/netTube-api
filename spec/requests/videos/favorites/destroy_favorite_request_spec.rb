require 'rails_helper'

describe 'Delete Favorite' do
  let(:user) { create(:user) }
  let(:token) { Doorkeeper::AccessToken.new(resource_owner_id: user.id) }
  let(:video_params1) {
    { target_type: 'Video',
      video: {
      etag: "string",
      youtube_id: "string_thing",
      img_high: "another_string",
      img_default: "default_string",
      title: "Title",
      published_at: DateTime.now,
      description: "It's a thing'"
    } }
  }
  
  let(:video_params2) {
    { target_type: 'Video',
      video: {
      etag: "string2",
      youtube_id: "string_thing2",
      img_high: "another_string2",
      img_default: "default_string2",
      title: "Title2",
      published_at: DateTime.now,
      description: "It's a thing2"
    } }
  }
  
  before(:each) do
    allow_any_instance_of(ApiController).to receive(:doorkeeper_token).and_return(token)
    post api_v1_user_favorites_path(user), params: video_params1
  end
  
  it 'should delete favorites' do
    delete api_v1_user_favorite_path(user.id, Favorite.last.id)
    
    expect(response).to be_successful
    expect(Favorite.count).to eq(0)
  end
  
  it 'should only delete the specified favorite' do
    post api_v1_user_favorites_path(user), params: video_params2
    expect(Favorite.count).to eq(2)
    
    delete api_v1_user_favorite_path(user.id, Favorite.last.id)
    
    video = Favorite.last.target
    expect(Favorite.count).to eq(1)
    expect(video.title).to eq(video_params1[:video][:title])
  end

  it 'should decrement Video#number_of_favorites' do
    user_2 = create(:user)
    create(:favorite, user: user_2, target: Video.last)
    expect(Video.last.number_of_favorites).to eq(2)
    
    favorite = user.favorites.find_by(target: Video.last)
    
    delete api_v1_user_favorite_path(user.id, favorite.id)
    expect(Video.last.number_of_favorites).to eq(1)
  end
end