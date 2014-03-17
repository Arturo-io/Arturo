module Transform
  mattr_accessor :plugins

  self.plugins = [NewLine]

  def self.execute(content, from = nil)
    plugins.inject(content) do |memo, plugin|
      memo = plugin.execute(memo, from)
    end
  end
end
