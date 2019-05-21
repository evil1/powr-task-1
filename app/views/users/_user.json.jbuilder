json.extract! user, :id, :external_id, :login, :name, :jsonObject, :created_at, :updated_at
json.url user_url(user, format: :json)
