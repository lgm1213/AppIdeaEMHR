class ProceduresController < ApplicationController
  before_action :set_procedure, only: %i[ edit update destroy ]

  # GET /:slug/procedures
  def index
    @procedures = @current_organization.procedures.order(:code)
  end

  # GET /:slug/procedures/new
  def new
    @procedure = @current_organization.procedures.build
  end

  # GET /:slug/procedures/1/edit
  def edit
  end

  # POST /:slug/procedures
  def create
    @procedure = @current_organization.procedures.build(procedure_params)

    respond_to do |format|
      if @procedure.save
        format.html { redirect_to procedures_path, notice: "Procedure was successfully created." }
        format.json { render :index, status: :created, location: @procedure }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @procedure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /:slug/procedures/1
  def update
    respond_to do |format|
      if @procedure.update(procedure_params)
        format.html { redirect_to procedures_path, notice: "Procedure was successfully updated." }
        format.json { render :index, status: :ok, location: @procedure }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @procedure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:slug/procedures/1
  def destroy
    @procedure.destroy!

    respond_to do |format|
      format.html { redirect_to procedures_path, status: :see_other, notice: "Procedure was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_procedure
    @procedure = @current_organization.procedures.find(params[:id])
  end

  def procedure_params
    params.require(:procedure).permit(:organization_id, :code, :name, :price, :modifiers)
  end
end
