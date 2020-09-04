defmodule WebSvc.Schema.Custom.Types do
  use Absinthe.Schema.Notation

  @moduledoc """
  Custom Types for Filtering and other general purpose, reusable parts
  """

  # Filtering Enum
  @desc "The range comparison operator"
  enum :range_comparison do
    value(:eq, as: :equal_to, description: "Equal To")
    value(:lt, as: :less_than, description: "Less Than")
    value(:lteq, as: :less_than_or_equal_to, description: "Less Than or Equal To")
    value(:gt, as: :greater_than, description: "Greater Than")
    value(:gteq, as: :greater_than_or_equal_to, description: "Greater Than or Equal To")
    value(:neq, as: :not_equal_to, description: "Not Equal To")
    value(:contains, description: "Contains the Specified String")
    value(:starts_with, description: "Starts With")
    value(:ends_with, description: "Ends With")
    value(:is_null, description: "Is the value of field NULL")
  end

  # Filtering an attribute via the comparison for given values
  input_object :range_filters do
    field(:attribute, :string)
    field(:comparison, :range_comparison)
    field(:value, :string)
  end

  # Valid directions for ordering our results by.
  enum :direction do
    value(:asc, as: :ascending, description: "Ascending Order")
    value(:desc, as: :descending, description: "Descending Order")
  end

  # Order by :last_name, :asc
  input_object :sort_filter do
    field(:attribute, :string)
    field(:direction, :direction)
  end

  # The wrapper object
  input_object :criteria do
    field(:sort, :sort_filter)
    field(:offset, :integer)
    field(:limit, :integer)
  end

  # generic action response, separate from GraphQL error.
  # Success or failure, with a reason, and the ID of the object worked upon.
  # the latter two are optional
  # this isn't as ideal as just returning the manipulated object.  But in some
  # cases this is preferrable, when you want to give feedback to the user, without
  # just tossing a GraphQL error.
  object :status_result do
    field(:success, non_null(:boolean))
    field(:reason, :string)
    field(:id, :string)
    field(:result, :json)
  end
end
