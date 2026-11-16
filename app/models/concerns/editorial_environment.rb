module EditorialEnvironment
  extend ActiveSupport::Concern
  ENVIRONMENTS = { "dm" => "Jornal DM", "fect" => "FECT" }.freeze
  included do
    validates :environment, inclusion: { in: ENVIRONMENTS.keys }
    scope :in_environment, ->(value) { where(environment: value) }
  end
end
