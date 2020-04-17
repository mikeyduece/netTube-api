class CreatePlaylistVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :playlist_videos do |t|
      t.references :video, null: false, foreign_key: true
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :playlist_videos, %i[playlist_id video_id], unique: true
  end
end
