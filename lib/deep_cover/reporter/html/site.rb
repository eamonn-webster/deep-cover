# frozen_string_literal: true

module DeepCover
  require_relative 'base'
  require_relative 'index'
  require_relative 'source'

  module Reporter::HTML
    class Site < Reporter::Base
      include Memoize
      memoize :analysis

      def path
        Pathname(options[:output])
      end

      def save
        clear
        save_assets
        save_index
        save_pages
      end

      def clear
        path.mkpath
        path.rmtree
        path.mkpath
      end

      def compile_stylesheet(source, dest)
        Bundler.with_clean_env do
          `sass #{source} #{dest}`
        end
      end

      def render_index
        Tools.render_template(:index, Index.new(analysis, **options))
      end

      def save_index
        path.join('index.html').write(render_index)
      end

      def save_assets
        require 'fileutils'
        src = "#{__dir__}/template/assets"
        dest = path.join('assets')
        FileUtils.cp_r(src, dest)
        compile_stylesheet "#{src}/deep_cover.css.sass", dest.join('deep_cover.css')
        dest.join('deep_cover.css.sass').delete
      end

      def render_source(covered_code)
        Tools.render_template(:source, Source.new(analysis.analyser_map.fetch(covered_code), covered_code.name))
      end

      def save_pages
        coverage.each do |covered_code|
          dest = path.join("#{covered_code.name}.html")
          dest.dirname.mkpath
          dest.write(render_source(covered_code))
        end
      end

      def self.save(coverage, output:, **options)
        Site.new(coverage, output: output, **options).save
      end
    end
  end
end
