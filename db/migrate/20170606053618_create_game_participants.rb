class CreateGameParticipants < ActiveRecord::Migration[5.1]
  def change
    create_table :game_participants, id: :uuid do |t|
      t.belongs_to :game
      t.integer :summoner_id
      t.string :team
      t.integer :champion_id
      t.boolean :win
      t.integer :kills
      t.integer :deaths
      t.integer :assists

      t.timestamps
    end
  end
end
