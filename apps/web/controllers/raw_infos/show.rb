module Web
  module Controllers
    module RawInfos
      class Show
        include Web::Action

        expose :raw_info

        def call(params)
          result = ::RawInfos::Find.call(id: params[:id])
          @raw_info = result.raw_info
        end
      end
    end
  end
end
