defmodule Core.Model.Tenants do
  use Core.Context
  use Core.Model.CollectionUuid, model: Tenant
  require Logger
  alias Utils.Errors

  # signin policy:
  #   - anyone
  #   - matching:[domain,...]
  #   - invite only
  def one_with_domain!(clauses) do
    Repo.one(from(Tenant, where: ^clauses, preload: [:domains]))
  end

  def host_to_tenant(domain) when is_binary(domain) do
    [host | _] = String.split(domain, ":")
    # add configurable RX to simplify domain name to tenant
    # name = #Regex.replace(~r/rx$/i, host, "")
    name = host

    case Tenants.originate_tenant_by_domain(name) do
      {:ok, %Tenant{} = tenant} -> {:ok, tenant}
      {:error, %Ecto.Changeset{} = chgs} -> {:error, Errors.convert_error_changeset(chgs)}
      error -> error
    end
    |> case do
      {:ok, _} = pass ->
        pass

      {:error, msg} ->
        # make this loud and noisy - we are not configured properly
        Logger.error(msg)
        raise "unable to find tenant configuration"
    end
  end

  def get_or_create_tenant(domain) when is_binary(domain) do
    case TenantDomains.one(name: domain) do
      {:ok, %TenantDomain{} = domain} ->
        case Tenants.one(id: domain.tenant_id) do
          {:ok, %Tenant{} = result} ->
            {:ok, result}

          {:error, error} ->
            {:error, error}
        end

      _nope ->
        # if Application.get_env(:core, :create_tenant_on_auth, false) do
        #   create_tenant(domain)
        # else
        {:error, "Tenant #{domain} not defined"}
        # end
    end
  end

  def create_tenant(domain) when is_binary(domain) do
    case Tenants.replace(%{code: domain}, code: domain) do
      {:ok, %Tenant{} = result} ->
        case TenantDomains.replace(%{name: domain, tenant_id: result.id}, name: domain) do
          {:ok, %TenantDomain{} = dom} ->
            {:ok, %Tenant{result | domains: [dom], domain: dom.name}}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec originate_tenant_by_domain(String.t()) ::
          {:ok, Tenant.t()} | {:error, Ecto.Changeset.t() | any}
  def originate_tenant_by_domain(domain) when is_binary(domain) do
    case Core.HostCache.lookup(domain) do
      [{domain, result, _}] ->
        {:ok, %Tenant{result | domain: domain}}

      _no_cache ->
        case get_or_create_tenant(domain) do
          {:ok, %Tenant{} = tenant} ->
            # the 100 is to add some entropy so all the schedules don't run at the same time
            Core.HostCache.insert(domain, tenant, 900_100)
            {:ok, %Tenant{tenant | domain: domain}}

          pass ->
            pass
        end
    end
  end
end
