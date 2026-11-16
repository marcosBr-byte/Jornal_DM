class AssociateEditorialPhotos < ActiveRecord::Migration[8.1]
  def change
    add_reference :photo_submissions, :article, foreign_key: { on_delete: :nullify }
  end
end
