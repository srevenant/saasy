defmodule WebSvc.Schema.SaasySchema do
  use Absinthe.Schema.Notation
  use Timex
  require Logger

  @moduledoc """
  Graphql Types
  """

  scalar :factor_type do
    serialize(&Atom.to_string/1)
    parse(&FactorTypeEnum.cast/1)
  end

  @desc "An authentication factor"
  object :factor do
    field(:id, non_null(:string))
    field(:user_id, non_null(:string))
    field(:type, :factor_type)
    field(:name, :string)
    field(:expires_at, :integer)
    field(:details, :json)
  end

  @desc "Authorization Roles"
  object :role do
    field(:id, non_null(:string))
    field(:name, non_null(:string))
    field(:description, non_null(:string))
  end

  object :access do
    field(:actions, list_of(:string))
    field(:roles, list_of(:string))
  end

  @desc "Application Features and Settings"
  object :setting do
    field(:id, :string)
    field(:scope, :string)
    field(:name, :string)
    field(:value, :string)
  end

  object :setting_scheme do
    field(:id, :string)
    field(:scope, :string)
    field(:name, :string)
    field(:scheme, :json)
    field(:help, :string)
  end

  @desc "Application Features and Settings"
  object :setting do
    field(:id, :string)
    field(:scope, :string)
    field(:name, :string)
    field(:value, :string)
  end

  object :setting_scheme do
    field(:id, :string)
    field(:scope, :string)
    field(:name, :string)
    field(:scheme, :json)
    field(:help, :string)
  end

  object :api_key do
    field(:access, non_null(:string))
    field(:validation, non_null(:json))
  end

  object :invitations do
    field(:codes, list_of(non_null(:string)))
  end

  ##############################################################################
  object :saasy_queries do
  end

  ##############################################################################
  object :saasy_mutations do
    # field :get_invites, :invitations do
    #   resolve(&SaasyResolver.mutate_get_invites/2)
    # end

    # field :gen_api_key, :api_key do
    #   resolve(&SaasyResolver.mutate_gen_apikey/2)
    # end
  end
end
