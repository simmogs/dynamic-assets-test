class CustomTheme < ActiveRecord::Base

  def self.compile(theme_id)
    ThemeCompiler.new(theme_id).compute
  end

  def get_binding
    binding
  end

  def delete_asset
    return unless digest?

    if Rails.env.production?
      FOG_STORAGE.directories.get(ENV['FOG_DIRECTORY']).files.get(asset_path).try(:destroy)
    else
      path = File.join(Rails.root, 'public', asset_path)
      File.delete(path) if File.exists?(path)
    end
  end

  def asset_path(digest = self.digest)
    "assets/themes/#{asset_name(digest)}.css"
  end

  def asset_name(digest = self.digest)
     "#{id}-#{digest}"
  end

  def asset_url
    "#{ActionController::Base.asset_host}/#{asset_path}"
  end
end
