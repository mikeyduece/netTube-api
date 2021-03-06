require 'rails_helper'

describe 'Create Favorites' do
  let!(:user) { create(:user) }
  let!(:user_2) { create(:user) }
  let!(:playlist) { create(:playlist, user: user_2) }
  let(:token) { Doorkeeper::AccessToken.new(resource_owner_id: user.id) }
  let(:token_2) { Doorkeeper::AccessToken.new(resource_owner_id: user_2.id) }
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
  
  let(:playlist_params) {
    {
      target_type: 'Playlist',
      target_id: playlist.id
    }
    
  }
  
  before(:each) do
    allow_any_instance_of(ApiController).to receive(:doorkeeper_token).and_return(token)
  end
  
  it 'should create favorite' do
    post api_v1_user_favorites_path(user), params: video_params1
    
    expect(response).to be_successful
    
    video = Favorite.last.target
    
    expect(Favorite.count).to eq(1)
    expect(video.title).to eq(video_params1[:video][:title])
    expect(video.title).not_to eq(video_params2[:video][:title])
  end
  
  it 'should create more than one favorite' do
    post api_v1_user_favorites_path(user), params: video_params1
    expect(Favorite.count).to eq(1)
    
    post api_v1_user_favorites_path(user), params: video_params2
    expect(Favorite.count).to eq(2)
  end
  
  it 'should increment Video#increment_number_of_favorites' do
    post api_v1_user_favorites_path(user), params: video_params1
    expect(Video.last.number_of_favorites).to eq(1)
    
    allow_any_instance_of(ApiController).to receive(:doorkeeper_token).and_return(token_2)
    post api_v1_user_favorites_path(user_2), params: video_params1
    
    expect(Video.last.number_of_favorites).to eq(2)
  end

  it 'should create favorite for a playlist' do
    post api_v1_user_favorites_path(user), params: playlist_params
    
    playlist_favorite = parse_json(response.body)
    
    expect(playlist_favorite[:favorited]).to be(true)
  end
  
end