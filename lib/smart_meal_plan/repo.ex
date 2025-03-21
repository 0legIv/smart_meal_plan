defmodule SmartMealPlan.Repo do
  use Ecto.Repo,
    otp_app: :smart_meal_plan,
    adapter: Ecto.Adapters.Postgres
end
