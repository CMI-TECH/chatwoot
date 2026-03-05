# frozen_string_literal: true

class CreateLeadStages < ActiveRecord::Migration[7.0]
  def change
    create_table :lead_stages do |t|
      t.references :account, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.string :color, null: false, default: '#00D1FF'
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :lead_stages, [:account_id, :position]
    add_index :lead_stages, [:account_id, :name], unique: true
  end
end
