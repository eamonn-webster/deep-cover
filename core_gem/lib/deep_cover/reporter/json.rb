# frozen_string_literal: true

module DeepCover
  require_relative 'base'

  module Reporter
    class JSON < Base
      def path
        Pathname(options[:output])
      end

      def report
        path.join('deep_cover.json').write(stats_to_data.to_json)
      end

      def self.report(coverage, **options)
        JSON.new(coverage, **options).report
      end

      private

      def stats_to_data
        populate_stats do |full_path, partial_path, data, children|
          data = transform_data(data)
          if children.empty?
            {
              text: %{<a href="#{full_path}.html">#{partial_path}</a>},
              data: data,
            }
          else
            {
              text: partial_path,
              data: data,
              children: children,
              state: {opened: true},
            }
          end
        end
      end

      # {per_char: Stat, ...} => {per_char: {ignored: ...}, per_char_percent: 55.55, ...}
      def transform_data(data)
        Tools.merge(
          data.transform_values(&:to_h),
          *data.map { |type, stat| {:"#{type}_percent" => stat.percent_covered} }
        )
      end
    end
  end
end
