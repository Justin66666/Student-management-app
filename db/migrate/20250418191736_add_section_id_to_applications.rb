class AddSectionIdToApplications < ActiveRecord::Migration[8.0]
  def change
    add_reference :applications, :section, null: true, foreign_key: true
  end
end 