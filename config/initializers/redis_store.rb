redis_url = ENV["REDISCLOUD_URL"] || "redis://127.0.0.1:6379/0/ocarina"
Ocarina::Application.config.cache_store = :redis_store, redis_url
