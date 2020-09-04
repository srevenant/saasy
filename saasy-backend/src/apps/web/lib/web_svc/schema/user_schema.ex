defmodule WebSvc.Schema.UserSchema do
  use Absinthe.Schema.Notation
  use Timex
  alias WebSvc.Resolvers.UsersResolver
  alias Core.Model.Users
  require Logger

  @moduledoc """
  Graphql Types
  """

  @desc "An email address"
  object :email do
    field(:id, non_null(:string))
    field(:user_id, non_null(:string))
    field(:address, non_null(:string))
    field(:primary, non_null(:boolean))
    field(:verified, non_null(:boolean))
  end

  @desc "A phone number"
  object :phone do
    field(:id, non_null(:string))
    field(:user_id, non_null(:string))
    field(:number, non_null(:string))
    field(:primary, non_null(:boolean))
    field(:verified, non_null(:boolean))
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  @desc "A person (internal)"
  object :person do
    field(:id, :string)
    field(:name, :string)
    field(:last_seen, :datetime)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)

    field :verified, :boolean do
      resolve(&UsersResolver.resolve_verified_email/2)
    end

    field :handle, :string do
      resolve(&UsersResolver.reduce_handle/2)
    end

    field :settings, :json do
      resolve(&UsersResolver.resolve_settings/2)
    end

    field(:tenant_id, :string)

    field :emails, list_of(:email) do
      resolve(&UsersResolver.resolve_emails/2)
    end

    field :phones, list_of(:phone) do
      resolve(&UsersResolver.resolve_phones/2)
    end

    field :factors, list_of(:factor) do
      arg(:historical, :boolean, default_value: false)
      arg(:type, :string)
      resolve(&UsersResolver.resolve_factors/2)
    end

    field :access, :access do
      resolve(&UsersResolver.resolve_access/2)
    end

    field :auth_status, :auth_status do
      # note: only when my_auth queried as user==connection_user
      resolve(&UsersResolver.resolve_auth_status/2)
    end

    field :data, list_of(:user_data) do
      arg(:types, list_of(:string))
      resolve(&UsersResolver.resolve_user_data/3)
    end

    field(:files, list_of(:file)) do
      resolve(fn user, _, _ ->
        with {:ok, user} <- Users.preload(user, [:files]) do
          {:ok, user.files}
        end
      end)
    end

    field :avatar, :json do
      resolve(&UsersResolver.resolve_avatar/3)
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  @desc "a person (public)"
  object :public_person do
    field(:id, non_null(:string))

    field(:name, :string)

    field(:last_seen, :datetime)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)

    # todo: perhaps make this a primary value on the row
    field :verified, :boolean do
      resolve(&UsersResolver.resolve_verified_email/2)
    end

    field :handle, :string do
      resolve(&UsersResolver.reduce_handle/2)
    end

    field :data, list_of(:user_data) do
      arg(:types, list_of(:string))
      resolve(&UsersResolver.resolve_public_user_data/3)
    end

    # placeholder only
    field(:files, list_of(:file)) do
      resolve(fn _, _ ->
        {:ok, []}
      end)
    end

    field :avatar, :json do
      resolve(&UsersResolver.resolve_avatar/3)
    end
  end

  ## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  object :user_data do
    field(:id, :string)
    field(:type, :user_data_types)
    field(:value, :json)
  end

  input_object :input_user_data do
    field(:id, :string)
    field(:user_id, :string)
    field(:type, non_null(:string))
    field(:value, non_null(:string))
  end

  scalar :user_data_types do
    serialize(&Atom.to_string/1)
    parse(&UserDataTypesEnum.cast/1)
  end

  scalar :auth_status do
    description("""
    A token representing the status of the currently connected user's authentication
    """)

    serialize(&Atom.to_string/1)
    parse(&AuthXStatusEnum.cast/1)
  end

  object :public_person_result do
    field(:success, non_null(:boolean))
    field(:reason, :string)
    field(:result, :public_person)
  end

  object :person_result do
    field(:success, non_null(:boolean))
    field(:reason, :string)
    field(:result, :person)
  end

  object :public_people do
    field(:success, non_null(:boolean))
    field(:reason, :string)
    field(:total, :integer)
    field(:result, list_of(:public_person))
  end

  object :people do
    field(:success, non_null(:boolean))
    field(:reason, :string)
    field(:total, :integer)
    field(:results, list_of(:person))
  end

  input_object :people_filter do
    field(:name, :string)
    field(:handle, :string)
    field(:skills, list_of(:string))
    field(:types, list_of(:string))
    field(:roles, list_of(:string))
  end

  ##############################################################################
  object :user_queries do
    field :self, :person do
      resolve(&UsersResolver.query_self/2)
    end

    field :public_people, :public_people do
      arg(:filter, :people_filter)
      resolve(&UsersResolver.query_public_people/2)
    end

    field :people, :people do
      arg(:filter, :people_filter)
      resolve(&UsersResolver.query_people/2)
    end

    field :public_person, :person_result do
      arg(:target, :string)
      arg(:id, :string)
      resolve(&UsersResolver.query_public_person/2)
    end
  end

  ##############################################################################
  object :user_mutations do
    @doc "Only one thing is allowed to change at a time"
    field :update_person, type: :person_result do
      arg(:id, non_null(:string))
      arg(:name, :string)
      arg(:settings, :string)
      arg(:handle, :string)
      arg(:email, :string)
      arg(:rmemail, :string)
      arg(:verifyemail, :string)
      arg(:phone, :string)
      arg(:rmphone, :string)
      arg(:user_data, :input_user_data)
      resolve(&UsersResolver.mutate_update_person/2)
    end

    field :request_password_reset, :status_result do
      arg(:email, non_null(:string))
      resolve(&UsersResolver.request_password_reset/2)
    end

    field :change_password, :status_result do
      arg(:current, non_null(:string))
      arg(:new, non_null(:string))
      arg(:email, :string)
      resolve(&UsersResolver.mutate_change_password/2)
    end

    field :update_user, type: :person_result do
      arg(:id, non_null(:string))
      arg(:name, :string)
      arg(:settings, :string)
      arg(:handle, :string)
      resolve(&UsersResolver.mutate_update_user/2)
    end

    field :update_role, type: :person_result do
      arg(:id, non_null(:string))
      arg(:role, non_null(:string))
      resolve(&UsersResolver.mutate_update_role/2)
    end
  end
end
