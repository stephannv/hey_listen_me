module Web
  module Controllers
    module RawInfos
      class Index
        include Web::Action

        expose :raw_infos

        def call(params)
          result = ::RawInfos::List.call
          @raw_infos = result.raw_infos
        end
      end
    end
  end
end
