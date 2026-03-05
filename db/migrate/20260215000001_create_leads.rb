# frozen_string_literal: true

class CreateLeads < ActiveRecord::Migration[7.0]
  def change
    create_table :leads do |t|
      t.references :contact, null: false, foreign_key: true, index: true
      t.references :account, null: false, foreign_key: true, index: true
      t.references :conversation, null: true, foreign_key: true, index: true
      t.string :title, null: false
      t.text :description
      t.decimal :value, precision: 15, scale: 2, default: 0.0
      t.string :stage, null: false, default: 'lead'
      t.string :priority, null: false, default: 'medium'
      t.integer :assigned_user_id, index: true
      t.integer :created_by_id, null: false, index: true
      t.jsonb :custom_attributes, default: {}

      t.timestamps
    end

    add_index :leads, [:account_id, :stage]
    add_index :leads, [:account_id, :priority]
    add_index :leads, [:account_id, :created_at]
    add_foreign_key :leads, :users, column: :assigned_user_id
    add_foreign_key :leads, :users, column: :created_by_id
  end
end
