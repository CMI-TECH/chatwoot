class Api::V1::Accounts::LeadsController < Api::V1::Accounts::BaseController
  before_action :set_lead, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    @leads = Current.account.leads
                     .includes(:contact, :assigned_user, :created_by, :conversation)
                     .page(params[:page])

    # Apply filters
    @leads = @leads.by_stage(params[:stage]) if params[:stage].present?
    @leads = @leads.by_priority(params[:priority]) if params[:priority].present?
    @leads = @leads.assigned_to(params[:assigned_user_id]) if params[:assigned_user_id].present?

    # Apply sorting
    @leads = case params[:sort_by]
             when 'value'
               @leads.by_value
             when 'created_at'
               @leads.order(created_at: params[:sort_order] == 'asc' ? :asc : :desc)
             else
               @leads.recent
             end
  end

  def show; end

  def create
    @lead = Current.account.leads.new(lead_params)
    @lead.created_by = current_user
    @lead.assigned_user_id ||= current_user.id

    if @lead.save
      render json: @lead.webhook_data, status: :created
    else
      render json: { errors: @lead.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @lead.update(lead_params)
      render json: @lead.webhook_data
    else
      render json: { errors: @lead.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy
    head :no_content
  end

  private

  def set_lead
    @lead = Current.account.leads.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(
      :contact_id,
      :conversation_id,
      :title,
      :description,
      :value,
      :stage,
      :priority,
      :assigned_user_id,
      custom_attributes: {}
    )
  end

  def check_authorization
    authorize(Lead)
  end
end
