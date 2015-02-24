class CustomThemeController < ApplicationController

  def edit
    build_custom_theme
  end

  def create
    build_custom_theme
    @custom_theme.update_attributes(custom_theme_params)
    CustomTheme.compile(@custom_theme)
    redirect_to :root
  end

  private

  def custom_theme_params
    params.require(:custom_theme).permit!
  end

  def build_custom_theme
    @custom_theme = CustomTheme.first || CustomTheme.new
  end
end
