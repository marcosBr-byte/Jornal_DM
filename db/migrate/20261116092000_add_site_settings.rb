class AddSiteSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.string :environment, null: false
      t.boolean :uploads_enabled, default: true, null: false
      t.timestamps
    end
    add_index :site_settings, :environment, unique: true
    add_check_constraint :site_settings, "environment IN ('dm', 'fect')", name: "site_settings_environment"
  end
end
