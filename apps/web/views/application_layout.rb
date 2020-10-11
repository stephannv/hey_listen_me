module Web
  module Views
    class ApplicationLayout
      include Web::Layout

      def time_distance_with_date(datetime)
        "#{time_ago_in_words(datetime)} - (#{datetime})"
      end
    end
  end
end
