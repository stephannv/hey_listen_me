module RawInfos
  class List < Actor
    input :page, type: Integer, default: 1
    input :per_page, type: Integer, default: 20
    input :repository, type: RawInfoRepository, default: ->{ RawInfoRepository.new }

    output :raw_infos, type: Array

    def call
      self.raw_infos = repository.paginated(page: page, per_page: per_page).to_a
    end
  end
end
