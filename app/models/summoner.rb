class Summoner < ApplicationRecord
  validates :summoner_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  self.primary_key = :summoner_id

  has_many :game_participants
end
