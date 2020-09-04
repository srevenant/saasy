defmodule Core.Model.Factors do
  @moduledoc """
  Domain context for accessing and working with Factors in the system.
  """
  use Core.Context
  # TODO: external dependency of core causes compile time errors when releasing
  # use AuthX.ContextTypes
  @type str :: String.t()
  @type log_msg :: str
  @type usr_msg :: str
  @type auth_result :: {:ok | :error, AuthDomain.t()}
  use Core.Model.CollectionUuid, model: Factor

  # override the function brought in by the collection module
  def one_with_user_tenant(clauses) do
    case Repo.one(from(Factor, where: ^clauses, preload: [:user])) do
      %Factor{user: %User{} = user} = factor ->
        case Users.preload(user, :tenant) do
          {:ok, %User{} = preloaded} ->
            {:ok, %Factor{factor | user: preloaded}}

          err ->
            err
        end

      err ->
        err
    end
  end

  @doc """
  Preload factor's for a related model, with criteria

      Factors.preloaded_with(model, type)

  """
  def preloaded_with(model, type) when is_list(type) do
    now = Utils.Time.epoch_time(:second)

    Repo.preload(model, factors: from(a in Factor, where: a.type in ^type and a.expires_at > ^now))
  end

  def preloaded_with(model, type) when is_atom(type) do
    now = Utils.Time.epoch_time(:second)

    Repo.preload(model, factors: from(a in Factor, where: a.type == ^type and a.expires_at > ^now))
  end

  @doc """
  set a password

  Future change:

  change Factors so there is an archive state, some types when being cleaned
  are archived instead of deleted (such as passwords).

  Then AuthX.Signin.Local.load_password_factor should filter on !archived
  """
  def set_password(user, password) do
    Logger.info("setting password", user_id: user.id)
    {:ok, user} = Users.preload(user, [:tenant])

    case Factors.create(%{
           type: :password,
           expires_at: get_expiration(nil, :password),
           password: password,
           user_id: user.id,
           tenant_id: user.tenant.id
         }) do
      {:error, _} = pass ->
        pass

      {:ok, factor} ->
        Factors.all!(user_id: user.id, type: :password)
        |> Enum.each(fn oldf ->
          # TODO: future: mark aged but keep X copies
          if factor.id != oldf.id do
            Factors.delete(oldf)
          end
        end)

        {:ok, factor}
    end
  end

  defp get_expiration(provider_exp, type) do
    cfg = Application.get_env(:authx, :auth_expire_limits)
    def_exp = 86400 * 365

    # because of how releases bring in configs, this appears as a keyword
    # list in prod, vs a map in lower environs.  grr.
    expiration =
      if is_list(cfg) do
        Keyword.get(cfg, type, def_exp)
      else
        if is_map(cfg),
          do: Map.get(cfg, type, def_exp),
          else: def_exp
      end

    case {provider_exp, Utils.Time.epoch_time(:second) + expiration} do
      {nil, our_exp} ->
        our_exp

      {provider_exp, our_exp} when provider_exp >= our_exp ->
        our_exp

      {provider_exp, _our_exp} ->
        provider_exp
    end
  end

  # TODO: rename to set_federated_factor
  @spec set_factor(user :: User.t(), fedid :: AuthFedId.t()) :: auth_result
  def set_factor(user, fedid) do
    {:ok, user} = Users.preload(user, [:tenant])

    Factors.create(%{
      name: fedid.provider.kid,
      type: :federated,
      fedtype: fedid.provider.type,
      expires_at: get_expiration(fedid.provider.exp, :password),
      user_id: user.id,
      tenant_id: user.tenant.id,
      details: Map.from_struct(fedid.provider)
    })
  end

  def get_user_with_tenant(factor_id, tenant = %Tenant{}) do
    # load the factor and user, matching current tenant
    tenant_code = tenant.code

    case Factors.one_with_user_tenant(id: factor_id) do
      nil ->
        {:error, "Invalid tenant"}

      {:ok, %Factor{user: %User{tenant: %Tenant{code: ^tenant_code}}} = factor} ->
        {:ok, factor}

      {:ok, %Factor{}} ->
        {:error, "Factor in wrong tenant?"}

      {:error, _} ->
        {:error, "Cannot find identity factor=#{factor_id}"}
    end
  end

  def drop_expired() do
    now = Utils.Time.epoch_time(:second)
    from(f in Factor, where: f.expires_at < ^now) |> Repo.delete_all()
  end

  def all_not_expired!(%User{id: user_id}) do
    now = Utils.Time.epoch_time(:second)

    from(f in Factor, where: f.user_id == ^user_id and f.expires_at > ^now)
    |> Repo.all()
  end

  def all_not_expired!(%User{} = user, type) when is_binary(type),
    do: all_not_expired!(user, Utils.Types.to_atom(type))

  def all_not_expired!(%User{id: user_id}, type) when is_atom(type) do
    now = Utils.Time.epoch_time(:second)

    from(f in Factor, where: f.user_id == ^user_id and f.expires_at > ^now and f.type == ^type)
    |> Repo.all()
  end
end
