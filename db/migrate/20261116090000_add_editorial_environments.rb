class AddEditorialEnvironments < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :environment, :string, null: false, default: "dm"
    add_index :articles, [ :environment, :status, :published_at ]
    add_check_constraint :articles, "environment IN ('dm', 'fect')", name: "articles_environment"
    add_column :users, :editor_environment, :string
    add_check_constraint :users, "editor_environment IS NULL OR editor_environment IN ('dm', 'fect')", name: "users_environment"
    create_table :likes do |t|
      t.references :article, null: false, foreign_key: true
      t.string :visitor_digest, null: false
      t.timestamps
    end
    add_index :likes, [ :article_id, :visitor_digest ], unique: true
    create_table :comments do |t|
      t.references :article, null: false, foreign_key: true
      t.string :name, limit: 80
      t.text :body, null: false
      t.string :status, null: false, default: "pending"
      t.integer :reports_count, null: false, default: 0
      t.timestamps
    end
    add_index :comments, [ :article_id, :status, :created_at ]
    add_check_constraint :comments, "status IN ('pending', 'approved', 'rejected')", name: "comments_status"
    create_table :events do |t|
      t.string :environment, null: false, default: "dm"
      t.string :title, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.string :location, null: false
      t.string :category
      t.timestamps
    end
    add_index :events, [ :environment, :starts_at ]
    add_check_constraint :events, "environment IN ('dm', 'fect')", name: "events_environment"
    create_table :photo_submissions do |t|
      t.string :environment, null: false, default: "dm"
      t.string :contributor, limit: 80
      t.string :caption, limit: 220
      t.string :album, limit: 120
      t.string :status, null: false, default: "pending"
      t.bigint :original_bytes
      t.bigint :optimized_bytes
      t.integer :width
      t.integer :height
      t.timestamps
    end
    add_index :photo_submissions, [ :environment, :status, :created_at ]
    add_check_constraint :photo_submissions, "environment IN ('dm', 'fect')", name: "photos_environment"
    add_check_constraint :photo_submissions, "status IN ('pending', 'approved', 'rejected', 'published')", name: "photos_status"
  end
end
