class GameParticipantSerializer < ActiveModel::Serializer
  attribute :game_id, key: :gameId
  attribute :summoner_id, key: :summonerId
  attribute :champion_id, key: :championId
  attribute :lock_version, key: :lockVersion
  attributes :id, :team, :kills, :deaths, :assists, :win
end
