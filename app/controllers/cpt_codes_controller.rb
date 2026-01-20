class CptCodesController < ApplicationController
  def index
    @cpt_codes = CptCode.search_by_term(params[:query]).limit(20)
    render json: @cpt_codes.select(:id, :code, :description)
  end
end
