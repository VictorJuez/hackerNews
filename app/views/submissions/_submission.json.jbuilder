json.extract! submission, :id, :title, :url, :text, :created_at, :updated_at
json.url submission_url(submission, format: :json)
