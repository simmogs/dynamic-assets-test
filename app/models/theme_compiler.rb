class ThemeCompiler
  attr_reader :theme, :body, :tmp_themes_path, :tmp_asset_name, :compressed_body, :asset, :env

  def initialize(theme_id)
    @theme = CustomTheme.find(theme_id)
    @body = ERB.new(File.read(File.join(Rails.root, 'app', 'assets', 'stylesheets', 'zcustom.scss.erb'))).result(theme.get_binding)
    @tmp_themes_path = File.join(Rails.root, 'tmp', 'themes')
    @tmp_asset_name = theme.id.to_s
    @env = if Rails.application.assets.is_a?(Sprockets::Index)
      Rails.application.assets.instance_variable_get('@environment')
    else
      Rails.application.assets
    end
  end

  def compute
    create_temporary_file
    compile
    compress
    upload
  end

  private

  def compile
    @asset = env.find_asset(tmp_asset_name)
  rescue Sass::SyntaxError => error
    theme.revert
  end

  def compress
    @compressed_body = ::Sass::Engine.new(asset.body, {
      :syntax => :scss,
      :cache => false,
      :read_cache => false,
      :style => :compressed
    }).render
  end

  def create_temporary_file
    FileUtils.mkdir_p(tmp_themes_path) unless File.directory?(tmp_themes_path)
    File.open(File.join(tmp_themes_path, "#{tmp_asset_name}.scss"), 'w') { |f| f.write(body) }
  end

  def upload
    theme.delete_asset

    if Rails.env.production?
      FOG_STORAGE.directories.get(ENV['FOG_DIRECTORY']).files.create(
        :key    => theme.asset_path(asset.digest),
        :body   => StringIO.new(compressed_body),
        :public => true,
        :content_type => 'text/css'
      )
    else
      File.open(File.join(Rails.root, 'public', theme.asset_path(asset.digest)), 'w') { |f| f.write(compressed_body) }
    end

    theme.update_attribute(:digest, asset.digest)
  end
end
