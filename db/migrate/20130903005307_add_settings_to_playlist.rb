class AddSettingsToPlaylist < ActiveRecord::Migration
  def change
    add_column :playlists, :settings, :hstore
  end
end
