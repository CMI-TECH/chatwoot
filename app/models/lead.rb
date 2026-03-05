# == Schema Information
#
# Table name: leads
#
#  id                  :bigint           not null, primary key
#  contact_id          :bigint           not null
#  account_id          :bigint           not null
#  conversation_id     :bigint
#  title               :string           not null
#  description         :text
#  value               :decimal(15, 2)   default(0.0)
#  stage               :string           not null, default("lead")
#  priority            :string           not null, default("medium")
#  assigned_user_id    :integer
#  created_by_id       :integer          not null
#  custom_attributes   :jsonb            default({})
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Lead < ApplicationRecord
  # Associations
  belongs_to :contact
  belongs_to :account
  belongs_to :conversation, optional: true
  belongs_to :assigned_user, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User'

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :stage, presence: true, inclusion: {
    in: %w[lead aguardando_fatura negociacao troca_titularidade enviar_contrato contratos_assinados_cmf contrato_enviado declinados negocio_fechado]
  }
  validates :priority, presence: true, inclusion: {
    in: %w[low medium high]
  }
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :assigned_to, ->(user_id) { where(assigned_user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_value, -> { order(value: :desc) }

  # Enums (using string type)
  STAGES = %w[lead aguardando_fatura negociacao troca_titularidade enviar_contrato contratos_assinados_cmf contrato_enviado declinados negocio_fechado].freeze
  PRIORITIES = %w[low medium high].freeze

  # Callbacks
  after_create :dispatch_create_event
  after_update :dispatch_update_event
  after_destroy :dispatch_destroy_event

  # Instance methods
  def won?
    stage == 'negocio_fechado'
  end

  def lost?
    stage == 'declinados'
  end

  def active?
    !won? && !lost?
  end

  def move_to_stage(new_stage)
    return false unless STAGES.include?(new_stage)

    update(stage: new_stage)
  end

  def webhook_data
    {
      id: id,
      title: title,
      description: description,
      value: value,
      stage: stage,
      priority: priority,
      contact: contact.webhook_data,
      assigned_user: assigned_user&.push_event_data,
      created_by: created_by.push_event_data,
      custom_attributes: custom_attributes,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def dispatch_create_event
    Rails.configuration.dispatcher.dispatch(
      'lead.created',
      Time.zone.now,
      lead: self
    )
  end

  def dispatch_update_event
    Rails.configuration.dispatcher.dispatch(
      'lead.updated',
      Time.zone.now,
      lead: self,
      changed_attributes: previous_changes
    )
  end

  def dispatch_destroy_event
    Rails.configuration.dispatcher.dispatch(
      'lead.deleted',
      Time.zone.now,
      lead_data: webhook_data
    )
  end
end
