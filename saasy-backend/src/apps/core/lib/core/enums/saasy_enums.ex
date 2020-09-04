import EctoEnum

defenum(FactorTypeEnum,
  unknown: 0,
  password: 1,
  federated: 2,
  valtok: 3,
  apikey: 4,
  proxy: 5
)

defenum(FactorFederatedTypeEnum,
  none: 0,
  google: 1,
  linkedin: 2,
  facebook: 3,
  twitter: 4,
  twitch: 5
)

defenum(AuthAccessTypeEnum, action: 0, role: 1)

defenum(UserCodeTypesEnum, password_reset: 0, email_verify: 1)

defenum(UserTypesEnum,
  unknown: 0,
  identity: 1,
  identity_signedout: 3,
  authed: 2,
  hidden: 4,
  disabled: 200
)

# note: using a cross-project global namespace on this -- just comment out what isn't part of this project
defenum(UserDataTypesEnum,
  available: 0,
  # university: 1,
  address: 2,
  # promo1_data: 3,
  profile: 4,
  toggles: 5,
  save: 6
)
