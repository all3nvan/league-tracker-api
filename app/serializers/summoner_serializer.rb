class SummonerSerializer < ActiveModel::Serializer
  attribute :summoner_id, key: :summonerId
  attributes :name
end
