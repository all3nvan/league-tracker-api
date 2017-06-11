class GameSerializer < ActiveModel::Serializer
  attribute :game_id, key: :gameId

  has_many :game_participants, key: :gameParticipants, serializer: GameParticipantSerializer
end
