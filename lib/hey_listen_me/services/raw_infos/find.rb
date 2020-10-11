module RawInfos
  class Find < Actor
    input :id, type: String
    input :repository, type: RawInfoRepository, default: ->{ RawInfoRepository.new }

    output :raw_info, type: RawInfo

    def call
      self.raw_info = repository.find_with_events(id)
    end
  end
end
