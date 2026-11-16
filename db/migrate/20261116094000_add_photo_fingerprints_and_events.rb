class AddPhotoFingerprintsAndEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :photo_submissions, :fingerprint, :string
    add_index :photo_submissions, [ :environment, :fingerprint ], unique: true
    add_reference :photo_submissions, :event, foreign_key: { on_delete: :nullify }
  end
end
