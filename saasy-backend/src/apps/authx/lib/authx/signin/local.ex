defmodule AuthX.Signin.Local do
  @moduledoc """
  Local login scheme
  """
  require Logger
  use Core.ContextClient
  use AuthX.ContextTypes
  import Users, only: [check_user_status: 1]

  ##############################################################################
  # input:  %Tenant, %{'handle'=>, 'password'=>, 'email'=>})
  # output: {status<:error,:ok>, %AuthDomain{}, {logerror, puberror}}
  @spec create(Tenant.t(), params :: Map.t()) :: auth_result
  def create(
        %Tenant{} = tenant,
        %{"handle" => handle, "password" => password, "email" => eaddr}
      ) do
    case UserEmails.one([address: eaddr], [:user]) do
      {:ok, %UserEmail{}} ->
        {:error, %AuthDomain{error: "A signin already exists for `#{eaddr}`"}}

      _ ->
        Users.signup(%AuthDomain{
          tenant: tenant,
          input: %{
            handle: UserHandles.gen_good_handle(handle),
            secret: password,
            email: %{address: eaddr, verified: false}
          }
        })
    end
  end

  def create(_, _) do
    {:error,
     %AuthDomain{log: "auth signup failed, arguments don't match", error: "Signup Failed"}}
  end

  ##############################################################################
  # pipeline:
  #
  #    {:ok, %AuthDomain{}}
  #    {:error, %AuthDomain{status: :unknown, fail_inner:.., fail_outer:..}
  #
  # input:  (%AuthDomain{}, %{params})
  # output: {status<:error,:ok>, %AuthDomain{}, {logerror, puberror}}
  @spec check(AuthDomain.t(), params :: Map.t()) :: auth_result
  def check(%AuthDomain{} = auth, %{"handle" => handle, "password" => password}) do
    {:ok, auth}
    |> load_user(handle)
    |> check_user_status
    |> load_password_factor
    |> valid_user_factor(password)
    |> post_signin
  end

  # input:  (%Tenant{}, %{params}) # variant call, create the AuthDomain
  @spec check(Tenant.t(), params :: Map.t()) :: auth_result
  def check(%Tenant{} = tenant, args = %{"handle" => _, "password" => _}) do
    %AuthDomain{tenant: tenant}
    |> check(args)
  end

  ##############################################################################
  @spec load_user(auth_result, handle :: String.t()) :: auth_result
  defp load_user({:ok, %AuthDomain{} = auth}, handle) do
    IO.inspect({"LOADING", handle, auth})

    if String.contains?(handle, "@") do
      case UserEmails.one([address: handle], [:user]) do
        {:ok, email} ->
          {:ok, %AuthDomain{auth | user: email.user}}

        _ ->
          {:error, %AuthDomain{log: "Cannot find email #{handle}"}}
      end
    else
      case UserHandles.one([handle: handle], [:user]) do
        {:ok, handle} ->
          {:ok, %AuthDomain{auth | handle: handle, user: handle.user}}

        _ ->
          {:error, %AuthDomain{log: "Cannot find person ~#{handle}"}}
      end
    end
  end

  ##############################################################################
  @spec load_password_factor(auth_result) :: auth_result
  def load_password_factor({:ok, auth = %AuthDomain{user: user = %User{}}}) do
    user = Factors.preloaded_with(user, :password)

    case user.factors do
      [] ->
        Logger.metadata(uid: user.id)
        {:error, %AuthDomain{auth | log: "No auth factor for user"}}

      [factor | _] ->
        Logger.metadata(uid: user.id)
        {:ok, %AuthDomain{auth | factor: factor}}
    end
  end

  @spec load_password_factor(auth_result) :: auth_result
  def load_password_factor(pass = {:error, %AuthDomain{}}), do: pass

  ##############################################################################
  @doc """
      iex> password = "Bad Wolf"
      iex> hashed = Utils.Hash.password(password)
      iex> check_password(hashed, password)
      true
      iex> check_password(hashed, "Time Lord")
      false
  """
  @spec check_password(hash :: String.t() | User.t(), password :: String.t()) :: Boolean.t()
  def check_password(%User{} = user, password) do
    case load_password_factor({:ok, %AuthDomain{user: user}}) do
      {:ok, %AuthDomain{factor: %Factor{hash: hashed}}} ->
        check_password(hashed, password)

      _other ->
        false
    end
  end

  def check_password(hash, password) when is_binary(hash) and not is_nil(hash) do
    Utils.Hash.verify(password, hash)
  end

  def check_password(_, _), do: false

  @doc """
  """
  @spec valid_user_factor(auth_result, password :: String.t()) :: auth_result
  def valid_user_factor(
        {:ok, auth = %AuthDomain{user: %User{}, factor: %Factor{hash: hashed}}},
        password
      )
      when not is_nil(hashed) and hashed != "N/A" do
    if check_password(hashed, password) do
      {:ok, %AuthDomain{auth | status: :authed}}
    else
      {:error, %AuthDomain{auth | log: "Invalid Password"}}
    end
  end

  @spec valid_user_factor(auth_result, any) :: auth_result
  def valid_user_factor({:ok, auth = %AuthDomain{}}, _) do
    {:error, %AuthDomain{auth | log: "No password factor exists for user"}}
  end

  @spec valid_user_factor(auth_result, any) :: auth_result
  def valid_user_factor(pass = {:error, %AuthDomain{}}, _), do: pass

  ##############################################################################
  @spec post_signin(auth_result) :: auth_result
  def post_signin({:ok, auth = %AuthDomain{status: :authed, user: %User{}}}) do
    # Logger.info("Signin Success", uid: user.id)
    # TODO: events/triggers to table/signin count, etc
    {:ok, auth}
  end

  @spec post_signin(auth_result) :: auth_result
  def post_signin(pass = {:error, %AuthDomain{}}), do: pass
end
