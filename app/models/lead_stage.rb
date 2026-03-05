# == Schema Information
#
# Table name: lead_stages
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  name        :string           not null
#  color       :string           not null, default("#00D1FF")
#  position    :integer          not null, default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LeadStage < ApplicationRecord
  # Associations
  belongs_to :account

  # Validations
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :color, presence: true, format: { with: /\A#[0-9A-F]{6}\z/i }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_validation :set_default_position, on: :create

  # Class methods
  def self.create_defaults_for_account(account)
    default_stages = [
      { name: 'Novo', color: '#00D1FF', position: 0 },
      { name: 'Qualificado', color: '#0080FF', position: 1 },
      { name: 'Proposta', color: '#FFA500', position: 2 },
      { name: 'Negociação', color: '#FFD700', position: 3 },
      { name: 'Ganho', color: '#00FF00', position: 4 },
      { name: 'Perdido', color: '#FF0000', position: 5 }
    ]

    default_stages.each do |stage_attrs|
      account.lead_stages.create!(stage_attrs)
    end
  end

  private

  def set_default_position
    return if position.present?

    max_position = account.lead_stages.maximum(:position) || -1
    self.position = max_position + 1
  end
end
