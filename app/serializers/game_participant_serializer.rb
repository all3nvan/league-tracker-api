class GameParticipantSerializer < ActiveModel::Serializer
  # TODO: Include gameId? Front end might need it
  attribute :summoner_id, key: :summonerId
  attribute :champion_id, key: :championId
  attributes :id, :team, :kills, :deaths, :assists, :win
end
