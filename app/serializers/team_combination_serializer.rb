class TeamCombinationSerializer < ActiveModel::Serializer
  attribute :blue_team_summoner_ids, key: :blueTeamSummonerIds
  attribute :red_team_summoner_ids, key: :redTeamSummonerIds
  attribute :match_quality, key: :matchQuality
end
