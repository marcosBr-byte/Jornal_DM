module Admin
  class CategoriesController < BaseController
    def index
      @categories = editorial_scope(Category).order(:environment, :name)
    end
    def create
      category = Category.new(params.require(:category).permit(:name, :environment))
      authorize_environment!(category)
      if category.save
        redirect_to admin_categories_path, notice: "Categoria criada.", status: :see_other
      else
        redirect_to admin_categories_path, alert: category.errors.full_messages.to_sentence, status: :see_other
      end
    end
    def destroy
      category = editorial_scope(Category).find(params[:id])
      if Article.in_environment(category.environment).where(category: category.name).exists? || Article::CATEGORIES.include?(category.name)
        redirect_to admin_categories_path, alert: "Categorias originais ou em uso devem ser preservadas.", status: :see_other
      else
        category.destroy!
        redirect_to admin_categories_path, notice: "Categoria excluída.", status: :see_other
      end
    end
  end
end
