json.extract! submit, :id, :title, :url, :created_at, :updated_at
json.url submit_url(user, format: :json)
