class SummonerRatingSerializer < ActiveModel::Serializer
  attribute :summoner_id, key: :summonerId
  attributes :rating, :wins, :losses
end
