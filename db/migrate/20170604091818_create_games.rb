class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games, primary_key: :game_id do |t|
      t.timestamp :create_time

      t.timestamps
    end
  end
end
