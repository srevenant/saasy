use Mix.Config

config :authx,
  jwt_acc_secrets: [
    "vJ8Uy0inevJkHADvEENnn0FY4oVnWSMbj/zk0s5o13c="
  ],
  jwt_val_secrets: [
    "8E4IgHaPN9xkXsmjMxnK/m6aR17Ara9KJ+jZkd6dJME="
  ],
  auth_cxs_allowed: %{
  },
  # intentionally dialing up acc for DEV environs only - IN SECONDS
  auth_expire_limits: %{
    # Validation Tokens get 1 year
    val: %{
      # 30 days
      user: 60 * 60 * 24 * 30,
      # 1 day
      proxy: 60 * 60 * 24 * 1,
      # API key is 1 year
      apikey: 60 * 60 * 24 * 365
    },
    # Refresh Request Tokens get 15 minutes
    #    ref: 15 * 60,
    ref: 15 * 60,
    # User Access Tokens are 1 day (DEV only)
    #    acc: 60 * 60 * 24,
    acc: 1 * 60,
    # Cross Service User Access Tokens are 15 minutes
    cxs: 15 * 60,
    password: 365 * 86400
  }
