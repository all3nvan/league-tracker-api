class GameParticipantSerializer < ActiveModel::Serializer
  attribute :summoner_id, key: :summonerId
  attribute :champion_id, key: :championId
  attributes :team, :kills, :deaths, :assists
end
