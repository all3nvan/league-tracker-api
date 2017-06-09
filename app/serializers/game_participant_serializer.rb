class GameParticipantSerializer < ActiveModel::Serializer
  attributes :summoner_id, :team, :champion_id, :kills, :deaths, :assists
end
