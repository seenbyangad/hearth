# Connects the app to OpenAI. The key lives in the .env file (never commit it!)
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
end
