class GameSerializer < ActiveModel::Serializer
  # TODO: Prob include create_time in order to sort and display on front end
  attribute :game_id, key: :gameId

  has_many :game_participants, key: :gameParticipants, serializer: GameParticipantSerializer
end
