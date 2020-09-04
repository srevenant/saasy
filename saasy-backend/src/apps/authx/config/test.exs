use Mix.Config

config :authx,
  jwt_acc_secrets: [
    "nFVMU0UuLi5ptNaEa+paBS7JVBhYa62MqZOnT51KKjE="
  ],
  jwt_val_secrets: [
    "kMVYlHJdT1Pc8PNjo48xrObO4OgjQsoxNRq2Ma1QYRV="
  ],
  auth_cxs_allowed: %{
  },
  auth_expire_limits: %{
    # Validation Tokens get 1 year
    val: %{
      user: 60 * 60 * 24 * 30,
      proxy: 60 * 60 * 24 * 1,
      apikey: 60 * 60 * 24 * 365
    },
    # Refresh Request Tokens get 15 minutes
    ref: 15 * 60,
    # User Access Tokens are 15 minutes
    acc: 15 * 60,
    # Cross Service User Access Tokens are 15 minutes
    cxs: 15 * 60,
    password: 365 * 86400
  }
