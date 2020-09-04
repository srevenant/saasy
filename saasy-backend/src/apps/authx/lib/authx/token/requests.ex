# original content from Protos LLC/Brandon Gillespie, License for use per addendum (exhibit A) to noncompete/nda
defmodule AuthX.Token.Requests do
  @moduledoc """
  TokenRequest management
  """
  require Logger
  import AuthX.Settings
  alias AuthX.Token
  use Core.ContextClient

  # TODO: move to settings
  @auth_token_types [:acc, :cxs, :val, :ref]

  def create(%Token.Request{type: type})
      when type not in @auth_token_types do
    raise ArgumentError, "Invalid token type #{type}, not in #{inspect(@auth_token_types)}"
  end

  def create(request = %Token.Request{exp: exp, type: type}) when is_nil(exp) do
    create(%Token.Request{request | exp: expire_limit(type)})
  end

  def create(request = %Token.Request{secret: secret, type: type}) when is_nil(secret) do
    create(%Token.Request{request | secret: current_jwt_secret(type)})
  end

  def create(%Token.Request{tenant: %Tenant{} = tenant, tenant_code: code} = req)
      when is_nil(code) do
    create(%Token.Request{req | tenant_code: tenant.code})
  end

  def create(%Token.Request{for: scope} = req) when not is_map(scope) do
    create(%Token.Request{req | for: %{}})
  end

  def create(%Token.Request{
        sub: sub,
        exp: exp,
        tenant_code: tenant_code,
        type: type,
        secret: secret,
        for: scope
      })
      when is_binary(tenant_code) do
    signer = Joken.Signer.create("HS256", secret)

    {:ok, claims} =
      Joken.generate_claims(%{}, %{
        sub: sub,
        aud: "caa1:#{type}:#{tenant_code}",
        exp: Utils.Time.epoch_time(:second) + exp,
        for: scope
      })

    {:ok, jwt, _claims} = Joken.encode_and_sign(claims, signer)
    jwt
  end

  # really for testing, least efficient
  def create(req) when is_list(req), do: create(struct(Token.Request, req))

  ###########################################################################
  @doc ~S"""
  Generate an auth JWT to our specification

      iex> token = access_token("cas1:AB", 5*60, "example.com")
      iex> token.claims[:aud]
      "caa1:acc:example.com"
      iex> token.claims[:sub]
      "cas1:AB"
      iex> String.slice(token.token, 0..1)
      "ey"
  """
  def access_token(%Factor{} = factor) do
    create(%Token.Request{
      sub: "cas1:#{factor.id}",
      exp: AuthX.Settings.expire_limit(:acc),
      tenant_code: factor.user.tenant.code,
      type: :acc
    })
  end

  def access_token(sub, exp, tenant_code) when is_integer(exp) and is_binary(tenant_code) do
    create(%Token.Request{sub: sub, exp: exp, tenant_code: tenant_code, type: :acc})
  end

  def access_token(sub, tenant_code) when is_binary(tenant_code) do
    create(%Token.Request{sub: sub, tenant_code: tenant_code, type: :acc})
  end

  def cxs_token(app, exp, tenant_code) when is_binary(tenant_code) do
    create(%Token.Request{sub: app, exp: exp, tenant_code: tenant_code, type: :cxs})
  end

  # age_offset is used for testing

  #  TODO: map type :val / :apikey -- strike :apikey as a factor type, just have it as a variant of :val, and add {t: apikey} to scope of claims

  def gen_valtok_from_factor!(%Factor{} = factor, scope, user, age_offset \\ 0) do
    val_age = AuthX.Settings.expire_limit(:val) + age_offset

    AuthX.Token.Requests.create(
      sub: "cas1:#{factor.id}",
      scope: scope,
      tenant_code: user.tenant.code,
      exp: val_age,
      type: :val
    )
  end

  def validation_token(%User{} = user, scope, _type, age_offset \\ 0) when is_map(scope) do
    val_age = AuthX.Settings.expire_limit(:val) + age_offset
    secret = Utils.RandChars48.random()

    {:ok, %User{} = user} = Users.preload(user, :tenant)

    # create a validation JWT
    case Factors.create(%{
           name: "valtok",
           user_id: user.id,
           type: :valtok,
           value: secret,
           expires_at: Utils.Time.epoch_time(:second) + val_age
         }) do
      {:ok, %Factor{} = factor} ->
        {:ok, gen_valtok_from_factor!(factor, scope, user, age_offset), secret, factor}

      # AuthX.Token.Requests.create(
      #   sub: "cas1:#{factor.id}",
      #   scope: scope,
      #   tenant_code: user.tenant.code,
      #   exp: val_age,
      #   type: :val
      # ),

      error ->
        Logger.error("Unable to create Auth Token record in DB! #{inspect(error)}")
        error
    end
  end

  # this is use for internal testing
  def refresh_token!(user, scope, type, age_offset \\ 0) when is_map(scope) do
    {:ok, val_tok, val_sec, _factor} = validation_token(user, scope, type, age_offset)

    req_age = AuthX.Settings.expire_limit(:ref) + age_offset

    {:ok, %User{} = user} = Users.preload(user, :tenant)

    # create a request JWT
    AuthX.Token.Requests.create(
      sub: "cas2:#{val_tok.token}",
      exp: req_age,
      tenant_code: user.tenant.code,
      type: :ref,
      secret: val_sec
    ).token
  end
end
