class GameSerializer < ActiveModel::Serializer
  attributes :game_id

  has_many :game_participants, serializer: GameParticipantSerializer
end
