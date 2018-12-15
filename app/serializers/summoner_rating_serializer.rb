class SummonerRatingSerializer < ActiveModel::Serializer
  attribute :summoner_id, key: :summonerId
  attributes :rating
end
