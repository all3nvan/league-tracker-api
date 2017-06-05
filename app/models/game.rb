class Game < ApplicationRecord
  validates :create_time, presence: true
  validates :game_id, presence: true, uniqueness: true

  self.primary_key = :game_id

  has_many :game_participants
end
