class CreateSummoners < ActiveRecord::Migration[5.1]
  def change
    create_table :summoners, primary_key: :summoner_id do |t|
      t.string :name

      t.timestamps
    end
  end
end
