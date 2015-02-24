class SubmitsController < ApplicationController

  def create
    new_color = params[:color]
    redirect_to :root
  end
end
