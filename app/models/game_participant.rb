class GameParticipant < ApplicationRecord
  validates :team, presence: true
  validates :champion_id, presence: true
  validates :kills, presence: true
  validates :deaths, presence: true
  validates :assists, presence: true

  belongs_to :game, foreign_key: :game_id
  belongs_to :summoner, foreign_key: :summoner_id, optional: true
end
