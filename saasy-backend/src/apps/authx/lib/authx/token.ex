defmodule AuthX.Token do
  @moduledoc """
  Validate tokens are meeting our requirements

  NEW version, which uses %AuthDomain instead of %Plug.Conn
  """
  require Logger
  use Core.ContextClient
  import Utils.Types, only: [atom_keys: 1, to_atom: 1]
  #  require Joken

  #  @auth_token_types [:acc, :cxs, :val, :ref]
  # access <any>
  # cross-service

  ###########################################################################
  @doc ~S"""
  xex> token = AuthX.Token.Requests.access_token("cas1:AC", 5, "example.com")
  x..> {:ok, auth} = check_claims(%Core.Model.AuthDomain{tenant: %Core.Model.Tenant{code: "example.com"}, token: %{claims: token.claims}})
  xrue

  """
  def check(%AuthDomain{tenant: %Tenant{}, token: %{ref: _ref, claims: claims}} = auth)
      when is_map(claims) do
    # order matters
    # - audience parses the token type
    # - expiration is based on the token type
    # - after which it is worth looking up the subject
    # - signature is different based on audience/type and the subject, so do it last
    amerge(auth, %{claims: atom_keys(claims)})
    |> split_claims
    |> valid_audience
    |> valid_expiration
    |> valid_subject

    # note: signature validation is done as a separate cycle (varies by :acc or :val)
  end

  ###########################################################################
  # split out the pertinent bits of the claim
  defp split_target(key, val) do
    with [type, value] <- String.split(val, ":", parts: 2) do
      {:ok, Map.new([{key, value}, {to_atom(Atom.to_string(key) <> "_type"), to_atom(type)}])}
    else
      _err ->
        raise "Cannot parse token.#{key}=#{val}"
    end
  end

  defp split_claims(
         {:ok,
          %AuthDomain{
            token: %{
              claims: %{
                sub: subject,
                aud: audience
              }
            }
          } = auth}
       ) do
    with {:ok, sub} <- split_target(:sub, subject),
         {:ok, aud} <- split_target(:aud, audience) do
      {:ok, %AuthDomain{auth | token: Map.merge(auth.token, Map.merge(aud, sub))}}
    else
      error ->
        aerror(auth, error)
    end
  end

  ###########################################################################
  # @doc """
  # Validation Token
  # """
  defp valid_audience(
         {:ok,
          %AuthDomain{
            token: %{
              aud: audience
            }
          } = auth}
       ) do
    case split_target(:tok, audience) do
      {:ok, map} ->
        tenant = map[:tok]

        case auth.tenant.code do
          ^tenant ->
            {:ok, %AuthDomain{auth | type: map[:tok_type], token: Map.merge(auth.token, map)}}

          _ ->
            aerror(auth, "Tenant doesn't match for token.aud")
        end

      {:error, reason} ->
        aerror(auth, reason)
    end
  end

  defp valid_audience({:error, %AuthDomain{}} = pass), do: pass

  ###########################################################################
  #  defp valid_expiration({:ok, conn, claims, context}) do
  defp valid_expiration(
         {:ok,
          %AuthDomain{
            token: %{
              claims: claims,
              tok_type: type
            }
          } = auth}
       ) do
    now = Utils.Time.epoch_time(:second)

    if claims[:exp] > now do
      max_exp = AuthX.Settings.expire_limit(type)
      delta = claims[:exp] - now

      if delta > max_exp do
        # , exp: delta, type: context.type, max: max_exp)
        aerror(auth, "Token expiration out of bounds")
      else
        {:ok, auth}
      end
    else
      aerror(auth, "Token Expired")
    end
  end

  defp valid_expiration({:error, _} = pass), do: pass

  ###########################################################################
  # @doc """
  # Validation Token
  # """
  defp valid_subject(
         {:ok,
          %AuthDomain{
            token: %{
              tok_type: :val,
              aud_type: :caa1,
              sub_type: :cas1,
              sub: subject
            }
          } = auth}
       ) do
    case Factors.get_user_with_tenant(subject, auth.tenant) do
      {:ok, %Factor{type: :valtok} = factor} ->
        if is_nil(factor.value) do
          aerror(auth, "Factor for token is not a validation factor")
        else
          {:ok, %AuthDomain{auth | factor: factor}}
        end

      {:error, error} ->
        {:error, %AuthDomain{auth | log: error}}
    end
  end

  # @doc """
  # Access Token
  # """
  defp valid_subject(
         {:ok,
          %AuthDomain{
            token: %{
              tok_type: :acc,
              sub_type: :cas1,
              sub: subject
            }
          } = auth}
       ) do
    case Factors.get_user_with_tenant(subject, auth.tenant) do
      # type: :valtok is correct. The factor is the parent validation token
      # which created this access token, we are just looking through it to the user
      {:ok, %Factor{type: :valtok} = factor} ->
        {:ok, %AuthDomain{auth | factor: factor, user: factor.user}}

      {:ok, %Factor{} = factor} ->
        IO.inspect({subject, factor})
        aerror(auth, "Provided factor is not a validation token")

      {:error, error} ->
        aerror(auth, error)
    end
  end

  defp valid_subject({:ok, %AuthDomain{token: %{claims: %{sub: sub}}} = auth}) do
    aerror(auth, "[valid_subject] Cannot parse token.sub=#{sub}")
  end

  defp valid_subject({:ok, %AuthDomain{} = auth}) do
    aerror(auth, "[valid_subject] Unable to process token subject")
  end

  defp valid_subject(pass), do: pass

  def validate_by_type(type, jwt) do
    secrets = AuthX.Settings.secret_keys(type)

    # because we want to support multiple secrets in parallel
    case Enum.find_value(secrets, fn secret -> verify_jwt!(jwt, secret) end) do
      false ->
        {:error, "Invalid authorization token #{type}"}

      nil ->
        {:error, "Token secret does not match #{type}"}

      result ->
        {:ok, result}
    end
  end

  ###########################################################################
  # utility wrappers
  def verify_jwt!(jwt, secret) do
    # not using Joken.with_verifier() because I want to enrich data along the way -BJG
    # called by Enum.find, expects a truthy value for success, just give the token
    #    case jwt
    #         |> Joken.token()
    #         |> Joken.with_signer(Joken.hs256(secret))
    #         |> Joken.verify!() do
    ## split out if this works (signer is done on init)
    case Joken.verify(jwt, Joken.Signer.create("HS256", secret)) do
      {:ok, claims} ->
        claims

      {:error, _error} ->
        false
    end
  end

  defp aerror(auth, reason) do
    {:error, %AuthDomain{auth | log: reason}}
  end

  defp amerge(auth, map) do
    {:ok, %AuthDomain{auth | token: Map.merge(auth.token, map)}}
  end

  # defp amerge!(auth, map) do
  #   %AuthDomain{auth | token: Map.merge(auth.token, map)}
  # end
end
