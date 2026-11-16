class AddEditorialCategories < ActiveRecord::Migration[8.1]
  def up
    create_table :categories do |t|
      t.string :environment, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :categories, [ :environment, :name ], unique: true
    add_check_constraint :categories, "environment IN ('dm', 'fect')", name: "categories_environment"
    # Copy every existing category without modifying articles.
    execute <<~SQL
      INSERT INTO categories (environment, name, created_at, updated_at)
      SELECT DISTINCT environment, category, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM articles
      ON CONFLICT DO NOTHING
    SQL
    %w[dm fect].each do |environment|
      [ "Educação", "Eventos", "Esportes", "Cultura", "Avisos", "Entrevistas", "Projetos", "Coberturas" ].each do |name|
        execute "INSERT INTO categories (environment, name, created_at, updated_at) VALUES (#{connection.quote(environment)}, #{connection.quote(name)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) ON CONFLICT DO NOTHING"
      end
    end
  end
  def down
    drop_table :categories
  end
end
