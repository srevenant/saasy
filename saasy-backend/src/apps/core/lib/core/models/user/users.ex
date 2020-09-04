defmodule Core.Model.Users do
  use Core.Context
  use Core.Model.CollectionUuid, model: Core.Model.User

  alias Core.Model.{
    UserHandles,
    UserEmails,
    Tenant,
    User,
    AuthDomain,
    AuthFedId,
    UserCode,
    UserCodes
  }

  alias Core.Email.SaasyTemplates

  import Core.Email.Sendmail

  def search(%{tenant_id: tenant_id, matching: matching, limit: limit}) do
    {:ok,
     Repo.all(
       from(u in User,
         join: e in UserEmail,
         where: e.user_id == u.id,
         join: h in UserHandle,
         where: h.user_id == u.id,
         where:
           u.tenant_id == ^tenant_id and
             (like(u.name, ^matching) or
                like(h.handle, ^matching) or
                like(e.address, ^matching)),
         limit: ^limit
       )
     )}
  rescue
    error ->
      {:error, error}
  end

  @doc """
  Bring in the list of authorized actions onto the user object (into :authz)
  """
  @spec get_authz(user :: User.t()) :: User.t()
  def get_authz(%User{} = user) do
    {:ok, user} = Users.preload(user, :accesses)
    %User{user | authz: Core.Model.Accesses.get_actions(user.accesses)}
  end

  def check_authz(user, action) do
    user = Users.get_authz(user)

    if MapSet.member?(user.authz, action) do
      {true, user}
    else
      {false, user}
    end
  end

  ################################################################################
  def user_seen(%User{} = user) do
    # Gah ecto queries... ideally:
    #   UPDATE users SET last_seen=NOW() WHERE id = ?
    update(user, %{last_seen: Timex.now()})
  end

  ################################################################################
  # @doc """
  # SignIn pipeline
  # """
  # def signin(%{handle: handle, password: password}, conn) do
  #   # going backwards here, but ohwell - BJG
  #   AuthX.Signin.check(conn, %{"handle" => handle, "password" => password})
  # end

  # redefined here instead of doing a circular import to AuthX
  @type auth_result :: {:ok | :error, AuthDomain.t()}

  ################################################################################
  @doc """
  SignUp pipeline
  """

  ##############################################################################
  ### TODO: check email first, have signup shift to give an error: that user already exists, if it is found
  @spec signup(Tenant.t(), params :: Map.t()) :: auth_result
  # def signup(tenant, %{handle: handle, email: email} = args)
  #     when handle == "",
  #     do: signup(tenant, Map.put(args, :handle, email))
  # def signup(tenant, %{handle: handle, email: email, password: password}) do
  #   {:ok, %AuthDomain{input: %{handle: handle, email: email, secret: password}, tenant: tenant}}

  def signup(%AuthDomain{} = auth) do
    {:ok, auth}
    |> signup_check_handle
    |> signup_create_user(:authed)
    # |> signup_add_password
    # TODO: be intelligent
    |> signup_add_factor
    |> signup_associate_handle
    |> signup_associate_email
    |> signup_add_new_user
    |> mainline

    # TODO: this should actually shift to a welcome new user dialog, which can ask for other account attributes
  end

  def signup(tenant, input) do
    {:error,
     %AuthDomain{
       log: "No match for signup with args:\n(#{inspect(tenant)}, #{inspect(input)}",
       error: "Sign up Failed"
     }}
  end

  # variant with less restrictions
  def signup_only_identity(%AuthDomain{} = auth) do
    {:ok, auth}
    |> signup_create_user(:identity)
    |> signup_associate_email
    |> mainline

    # TODO: this should actually shift to a welcome new user dialog, which can ask for other account attributes
  end

  # result is any as we ignore it
  @spec signup_abort_create(AuthDomain.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  defp signup_abort_create(auth) do
    if not is_nil(auth.user) do
      Users.delete(auth.user)
    end
  end

  defp signup_check_handle(pass = {:ok, auth = %AuthDomain{input: %{handle: handle}}}) do
    case UserHandles.available(handle) do
      {:ok, _available_msg} ->
        pass

      {:error, private, public} ->
        {:error, auth, {private, public}}
    end
  end

  defp signup_create_user(
         {:ok, auth = %AuthDomain{tenant: tenant = %Tenant{}, input: input}},
         type
       ) do
    name = Map.get(input, :name, "")
    settings = Map.get(input, :settings, %{})

    case Users.create(%{
           name: name,
           settings: settings,
           tenant: tenant,
           tenant_id: tenant.id,
           type: type
         }) do
      #    case Map.merge(params, %{tenant: tenant, tenant_id: tenant.id}) |> Users.create() do
      {:ok, user} ->
        {:ok, %AuthDomain{auth | status: type, user: user, created: true}}

      {:error, err} ->
        signup_abort_create(auth)
        {:error, auth, {"Failed to create user=#{inspect(err)}", "Unable to signup at this time"}}
    end
  end

  defp signup_add_factor({:error, _auth, _reason} = pass), do: pass

  defp signup_add_factor(
         {:ok,
          auth = %AuthDomain{
            user: %User{} = user,
            input: %{secret: secret}
          }}
       ) do
    case Factors.set_password(user, secret) do
      {:ok, %Factor{}} ->
        {:ok, auth}

      {:error, %Changeset{} = changeset} ->
        signup_abort_create(auth)
        {:error, auth, {"", Utils.Errors.convert_error_changeset(changeset)}}
    end
  end

  defp signup_add_factor(
         {:ok,
          auth = %AuthDomain{
            user: %User{} = user,
            input: %{fedid: %AuthFedId{} = fedid}
          }}
       ) do
    case Factors.set_factor(user, fedid) do
      {:ok, %Factor{} = factor} ->
        {:ok, %AuthDomain{auth | factor: factor}}

      {:error, %Changeset{} = changeset} ->
        signup_abort_create(auth)
        {:error, auth, {"", Utils.Errors.convert_error_changeset(changeset)}}
    end
  end

  defp signup_associate_handle({:error, _auth, _reason} = pass), do: pass

  defp signup_associate_handle(
         {:ok,
          auth = %AuthDomain{
            tenant: %Tenant{} = tenant,
            user: %User{} = user,
            input: %{handle: handle}
          }}
       ) do
    case UserHandles.create(%{handle: handle, user_id: user.id, tenant_id: tenant.id}) do
      {:ok, handle} ->
        {:ok, %AuthDomain{auth | handle: handle}}

      {:error, %Changeset{} = changeset} ->
        signup_abort_create(auth)

        {:error, auth, {"", Utils.Errors.convert_error_changeset(changeset)}}
    end
  end

  defp signup_associate_email({:error, _auth, _reason} = pass), do: pass

  defp signup_associate_email(
         {:ok,
          auth = %AuthDomain{
            tenant: %Tenant{},
            user: %User{} = user,
            input: %{email: %{address: eaddr, verified: status}}
          }}
       )
       when is_binary(eaddr) do
    case add_email(user, eaddr, status) do
      {:ok, email} ->
        {:ok, %AuthDomain{auth | email: email}}

      {:error, msg} ->
        signup_abort_create(auth)
        {:error, auth, {"", msg}}
    end
  end

  # TODO: merge better with learning resolver--that code should probably be here
  defp signup_add_new_user({:ok, auth = %AuthDomain{user: %User{} = user}}) do
    with {:ok, user} <- Users.update(user, %{settings: Map.put(user.settings, "newUser", true)}) do
      {:ok, %AuthDomain{auth | user: user}}
    end
  end

  # after success, create a new struct so we don't carry around unecessary or
  # insecure baggage
  defp mainline({:ok, auth = %AuthDomain{}}) do
    {:ok,
     %AuthDomain{
       user: auth.user,
       tenant: auth.tenant,
       handle: auth.handle,
       created: auth.created,
       status: auth.status
     }}
  end

  defp mainline({:error, _auth, {inner, outer}}) do
    {:error, %AuthDomain{log: inner, error: outer}}
  end

  def active_users!(since) do
    GamePlatformTypeEnums.values()
    |> Enum.reduce(%{}, fn platform, acc ->
      p = Atom.to_string(platform)

      Map.put(
        acc,
        platform,
        Repo.one(
          from(u in User,
            where:
              u.last_seen > ^since and
                fragment(
                  """
                  settings->'platform'->? IS NOT NULL
                  """,
                  ^p
                ),
            select: fragment("count(*)")
          )
        )
      )
    end)
  end

  def search_name!(tenant, pattern) do
    Repo.all(from(u in User, where: u.tenant_id == ^tenant and like(u.name, ^pattern)))
  end

  ##############################################################################
  @doc """
  Helper function which accepts either user_id or user, and calls the passed
  function with the user model loaded including any preloads.  Send preloads
  as [] if none are desired.
  """
  def with_user(%User{} = user, preloads, func) do
    case Users.preload(user, preloads) do
      {:error, _} = pass ->
        pass

      {:ok, %User{} = user} ->
        func.(user)
    end
  end

  def with_user(user_id, preloads, func) when is_binary(user_id) do
    case Users.one(user_id, preloads) do
      {:error, _} = pass ->
        pass

      {:ok, %User{} = user} ->
        func.(user)
    end
  end

  ##############################################################################
  def send_password_reset(%User{} = user, %UserEmail{} = email, %UserCode{} = code) do
    # let all emails on the account know
    with {:ok, user} <- Users.preload(user, :emails) do
      sendmail(user.emails, &SaasyTemplates.password_reset/2, [email, code])
    end
  end

  ##############################################################################
  def send_failed_change(%UserEmail{} = email, message) do
    sendmail(email, &SaasyTemplates.failed_change/2, message)
  end

  ##############################################################################
  def send_password_changed(%User{} = user) do
    with {:ok, user} <- Users.preload(user, :emails) do
      sendmail(user.emails, &SaasyTemplates.password_changed/2)
    end
  end

  ##############################################################################
  def all_since(time) do
    Repo.all(from(u in User, where: u.last_seen > ^time))
  end

  ##############################################################################
  @code_expire_mins 1440
  def add_email(user, eaddr, verified \\ false) do
    eaddr = String.trim(eaddr)

    # basic
    case UserEmails.one(address: eaddr) do
      {:ok, %UserEmail{} = email} ->
        Logger.warn("failed adding email", user_id: user.id, eaddr: eaddr)
        sendmail(email, &SaasyTemplates.failed_change/2, "add email to your account.")

        {:error, "That email already is associated with a different account"}

      {:error, _} ->
        # add it
        case UserEmails.create(%{
               user_id: user.id,
               tenant_id: user.tenant_id,
               verified: verified,
               address: eaddr
             }) do
          {:ok, %UserEmail{} = email} ->
            email = %UserEmail{email | user: user}
            send_verify_email(email)

            {:ok, email}

          {:error, chgset} ->
            {:error, Utils.Errors.convert_error_changeset(chgset)}
        end
    end
  end

  def send_verify_email(%UserEmail{address: eaddr, user: user} = email) do
    with {:ok, code} <-
           UserCodes.generate_code(email.user_id, :email_verify, @code_expire_mins, %{
             email_id: email.id
           }) do
      Logger.info("added email", user_id: user.id, eaddr: eaddr)
      sendmail(email, &SaasyTemplates.verification/2, code)
    end
  end

  def check_user_status({:ok, %AuthDomain{user: %User{type: :disabled}}}),
    do: {:error, %AuthDomain{error: "sorry, account is disabled"}}

  def check_user_status(%User{type: :disabled}) do
    {:error, %AuthDomain{error: "sorry, account is disabled"}}
  end

  def check_user_status(%User{} = user), do: {:ok, user}

  def check_user_status(pass) do
    pass
  end

  ##############################################################################
  def add_phone(user, phone) do
    # TODO: do an internal ph# validation
    phone = String.trim(phone)

    case UserPhones.one(user_id: user.id, number: phone) do
      {:ok, %UserPhone{} = phone} ->
        {:ok, phone}

      {:error, _} ->
        # add it
        case UserPhones.create(%{
               user_id: user.id,
               tenant_id: user.tenant_id,
               number: phone
             }) do
          {:ok, %UserPhone{} = phone} ->
            # TODO santity checks:
            # - pick primary
            # Logger.info("added phone", user_id: user.id, phone: phone)
            {:ok, phone}

          {:error, chgset} ->
            {:error, Utils.Errors.convert_error_changeset(chgset)}
        end
    end
  end
end
