class AddGradersRequiredToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :graders_required, :integer, default: 1, null: false
  end
end 