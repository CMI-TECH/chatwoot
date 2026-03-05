class Api::V1::Accounts::LeadStagesController < Api::V1::Accounts::BaseController
  before_action :set_lead_stage, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    @lead_stages = Current.account.lead_stages.ordered
    render json: @lead_stages
  end

  def show
    render json: @lead_stage
  end

  def create
    @lead_stage = Current.account.lead_stages.new(lead_stage_params)

    if @lead_stage.save
      render json: @lead_stage, status: :created
    else
      render json: { errors: @lead_stage.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @lead_stage.update(lead_stage_params)
      render json: @lead_stage
    else
      render json: { errors: @lead_stage.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @lead_stage.destroy
    head :no_content
  end

  private

  def set_lead_stage
    @lead_stage = Current.account.lead_stages.find(params[:id])
  end

  def lead_stage_params
    params.require(:lead_stage).permit(:name, :color, :position)
  end

  def check_authorization
    authorize(LeadStage)
  end
end
