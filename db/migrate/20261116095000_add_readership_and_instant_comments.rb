class AddReadershipAndInstantComments < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :reads_count, :bigint, null: false, default: 0
    add_index :articles, [ :environment, :reads_count ]
    add_check_constraint :articles, "reads_count >= 0", name: "articles_nonnegative_reads"
    create_table :article_readings do |t|
      t.references :article, null: false, foreign_key: true
      t.string :visitor_digest, null: false
      t.date :read_on, null: false
      t.timestamps
    end
    add_index :article_readings, [ :article_id, :visitor_digest, :read_on ], unique: true, name: "index_unique_daily_article_reading"
    change_column_default :comments, :status, from: "pending", to: "approved"
  end
end
