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
      fog_storage.directories.get(ENV['FOG_DIRECTORY']).files.get(asset_path).try(:destroy)
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

  def fog_storage
    @fog_storage ||= Fog::Storage.new(provider:                 'AWS',
                                      aws_access_key_id:        ENV['ACCESS_KEY_ID'],
                                      aws_secret_access_key:    ENV['SECRET_ACCESS_KEY']
                                      )
  end
end
