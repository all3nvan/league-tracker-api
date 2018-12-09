class AddLockVersionToGameParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :game_participants, :lock_version, :integer
  end
end
