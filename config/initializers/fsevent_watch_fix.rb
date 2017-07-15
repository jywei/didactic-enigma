module ActiveSupport
  class EventedFileUpdateChecker
    private

    def directories_to_watch
      dtw = (@files + @dirs.keys).map { |f| @ph.existing_parent(f) }
      dtw.compact!
      dtw.uniq!

      normalized_gem_paths = Gem.path.map { |path| File.join path, "" }
      dtw = dtw.reject do |path|
        normalized_gem_paths.any? { |gem_path| path.to_s.starts_with?(gem_path) }
      end

      @ph.filter_out_descendants(dtw)
    end
  end
end
