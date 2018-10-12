class GameSerializer < ActiveModel::Serializer
  attribute :game_id, key: :gameId
  attribute :create_time, key: :createTime

  has_many :game_participants, key: :gameParticipants, serializer: GameParticipantSerializer
end
