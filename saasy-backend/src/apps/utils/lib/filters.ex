defmodule Utils.Filters do
  import Ecto.Query, only: [from: 2]
  alias Utils.Criteria

  @doc """
  Resolves all the filters and criteria passed in from Resolver arguments.
  %{
    range_filters: range_filters,
    bool_filters: bool_filters,
    criteria: %{limit: limit, offset: offset, sort: {attribute, direction}}
  } = Filters.resolve(%{
    filters: filters,
    criteria: {criteria, fn -> UserTasks.default_sorting() end}
  })
  """
  def resolve(args) do
    %{filters: filter_args} = args
    {range_filters, bool_filters} = take(filter_args)

    %{
      # Reducing filters is the new cool way to do it.
      range_filters: reduce(range_filters),
      bool_filters: bool_filters,
      criteria: parse_criteria(args)
    }
  end

  defp parse_criteria(%{criteria: {criteria, default_sorting_fun}} = _args) do
    {:ok, %{limit: limit, offset: offset, order: {attribute, direction}}} =
      Criteria.take(criteria, default_sorting_fun)

    %{limit: limit, offset: offset, sort: {attribute, direction}}
  end

  @doc """
  Takes as input, a list of RangeFilter map objects and converts them to a keyword list of tuples
  """
  def reduce(filters \\ []) do
    filters
    |> Enum.map(fn x -> transform(x) end)
  end

  # Take out the :filters item from the options list
  @doc """
    Converts a keyword list of various options into filter options:

      iex> Filters.take([completed: false, filters: [%{attribute: "id", comparison: :equal_to, value: "1"}]])
      {[%{attribute: "id", comparison: :equal_to, value: "1"}], [completed: false]}
      iex> Filters.take([])
      {[], []}
  """
  def take(options \\ []) do
    # Does options have a keyword member called :filters?
    case List.keymember?(options, :filters, 0) do
      true ->
        # Boy, it sure does!
        {{:filters, range_filters}, bool_filters} = options |> List.keytake(:filters, 0)

        # Return a tuple that has the range filters list and the boolean filters list.
        {range_filters, bool_filters}

      false ->
        # Nope!
        {[], options}
    end
  end

  @doc """
  Converts :equal_to RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :equal_to, value: "1"})
      {:id, {:equal_to, "1"}}
  """
  def transform(%{attribute: attr, comparison: :equal_to, value: val} = _range_filter) do
    {sanitized_field(attr), {:equal_to, val}}
  end

  @doc """
  Converts :not_equal_to RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :not_equal_to, value: "1"})
      {:id, {:not_equal_to, "1"}}
  """
  def transform(%{attribute: attr, comparison: :not_equal_to, value: val} = _range_filter) do
    {sanitized_field(attr), {:not_equal_to, val}}
  end

  @doc """
  Converts :less_than RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :less_than, value: "1"})
      {:id, {:less_than, "1"}}
  """
  def transform(%{attribute: attr, comparison: :less_than, value: val} = _range_filter) do
    {sanitized_field(attr), {:less_than, val}}
  end

  @doc """
  Converts :less_than_or_equal_to RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :less_than_or_equal_to, value: "1"})
      {:id, {:less_than_or_equal_to, "1"}}
  """
  def transform(
        %{attribute: attr, comparison: :less_than_or_equal_to, value: val} = _range_filter
      ) do
    {sanitized_field(attr), {:less_than_or_equal_to, val}}
  end

  @doc """
  Converts :greater_than RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :greater_than, value: "1"})
      {:id, {:greater_than, "1"}}
  """
  def transform(%{attribute: attr, comparison: :greater_than, value: val} = _range_filter) do
    {sanitized_field(attr), {:greater_than, val}}
  end

  @doc """
  Converts :greater_than_or_equal_to RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :greater_than_or_equal_to, value: "1"})
      {:id, {:greater_than_or_equal_to, "1"}}
  """
  def transform(
        %{attribute: attr, comparison: :greater_than_or_equal_to, value: val} = _range_filter
      ) do
    {sanitized_field(attr), {:greater_than_or_equal_to, val}}
  end

  @doc """
  Converts :contains RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "name", comparison: :contains, value: "ar"})
      {:name, {:contains, "1"}}
  """
  def transform(%{attribute: attr, comparison: :contains, value: val} = _range_filter) do
    {sanitized_field(attr), {:contains, val}}
  end

  @doc """
  Converts :starts_with RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "name", comparison: :starts_with, value: "Mar"})
      {:name, {:starts_with, "Mar"}}
  """
  def transform(%{attribute: attr, comparison: :starts_with, value: val} = _range_filter) do
    {sanitized_field(attr), {:starts_with, val}}
  end

  @doc """
  Converts :ends_with RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "name", comparison: :ends_with, value: "ark"})
      {:name, {:ends_with, "ark"}}
  """
  def transform(%{attribute: attr, comparison: :ends_with, value: val} = _range_filter) do
    {sanitized_field(attr), {:ends_with, val}}
  end

  @doc """
  Converts :is_null "true", RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :is_null, value: "true"})
      {:id, {:is_null, true}}
  """
  def transform(%{attribute: attr, comparison: :is_null, value: "true"} = _range_filter) do
    {sanitized_field(attr), {:is_null, true}}
  end

  @doc """
  Converts :is_null "false", RangeFilter to a keyword list of tuples.

      iex> Filters.transform(%{attribute: "id", comparison: :is_null, value: "false"})
      {:id, {:is_null, false}}
  """
  def transform(%{attribute: attr, comparison: :is_null, value: "false"} = _range_filter) do
    {sanitized_field(attr), {:is_null, false}}
  end

  @doc """
  Apply the :is_null TRUE range filter to this query
  {:completed_at, {:is_null, "true"}})
  """
  def apply(%Ecto.Query{} = query, {attr, {:is_null, "true"}} = _constraint) do
    from(t in query, where: is_nil(field(t, ^sanitized_field(attr))))
  end

  @doc """
  Apply the :is_null FALSE range filter to this query
  {:completed_at, {:is_null, "false"}})
  """
  def apply(%Ecto.Query{} = query, {attr, {:is_null, "false"}} = _constraint) do
    from(t in query, where: not is_nil(field(t, ^sanitized_field(attr))))
  end

  @doc """
  Apply the :equal_to range filter to this query
  {:id, {:equal_to, "1"}})
  """
  def apply(%Ecto.Query{} = query, {attr, {:equal_to, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) == ^val)
  end

  @doc """
  Apply the :greater_than range filter to this query
  {:id, {:greater_than, "1"}})
  """
  def apply(%Ecto.Query{} = query, {attr, {:greater_than, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) > ^val)
  end

  @doc """
  Apply the :greater_than_or_equal_to range filter to this query
  {:id, {:greater_than_or_equal_to, "1"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:greater_than_or_equal_to, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) >= ^val)
  end

  @doc """
  Apply the :less_than range filter to this query
  {:id, {:less_than, "1"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:less_than, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) < ^val)
  end

  @doc """
  Apply the :less_than_or_equal_to range filter to this query
  {:id, {:less_than_or_equal_to, "1"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:less_than_or_equal_to, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) <= ^val)
  end

  @doc """
  Apply the :not_equal_to range filter to this query
  {:id, {:not_equal_to, "1"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:not_equal_to, val}} = _constraint) do
    from(t in query, where: field(t, ^sanitized_field(attr)) != ^val)
  end

  @doc """
  Apply the :contains range filter to this query
  {:taskTitle, {:contains, "ind the gol"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:contains, val}} = _constraint) do
    from(t in query,
      where: like(field(t, ^sanitized_field(attr)), ^("%" <> sanitized_value(val) <> "%"))
    )
  end

  @doc """
  Apply the :starts_with range filter to this query
  {:taskTitle, {:contains, "Find the go"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:starts_with, val}} = _constraint) do
    from(t in query,
      where:
        fragment(
          "(?) LIKE (?)",
          field(t, ^sanitized_field(attr)),
          ^(sanitized_value(val) <> "%")
        )
    )
  end

  @doc """
  Apply the :ends_with range filter to this query
  {:taskTitle, {:contains, "nd the gold"}}
  """
  def apply(%Ecto.Query{} = query, {attr, {:ends_with, val}} = _constraint) do
    from(t in query,
      where:
        fragment(
          "(?) LIKE (?)",
          field(t, ^sanitized_field(attr)),
          ^("%" <> sanitized_value(val))
        )
    )
  end

  # categoryName becomes :category_name
  defp sanitized_field(attr) when is_binary(attr) do
    attr
    |> Macro.underscore()
    |> String.to_existing_atom()
  end

  defp sanitized_field(attr) when is_atom(attr) do
    attr
  end

  # Sanitize this to prevent SQL DoS attacks
  defp sanitized_value(val) do
    inspect(val) |> String.replace(~r<[\\\"%_]>, "", global: true)
  end

  @doc """
  Apply the boolean timestamp filters. This allows filtering a timestamp attribute as though it
  were a Boolean field. If the timestamp is present, then queries asking for `true` will be returned.
  If the timestamp is blank, then queries asking for `false` will be returned. This function expects
  a filter function as bfilter_fun which indicates what "virtual fields" map to which actual fields.
  """
  def b_timestamp_filters(%Ecto.Query{} = query, nil, _bfilter_fun),
    do: b_timestamp_filters(query, [], fn -> [] end)

  def b_timestamp_filters(%Ecto.Query{} = query, bool_filters, _bfilter_fun)
      when bool_filters == [],
      do: query

  def b_timestamp_filters(%Ecto.Query{} = query, bool_filters, bfilter_fun) do
    Enum.reduce(bfilter_fun.(), query, fn {x, y, z}, acc ->
      b_timestamp_filter(acc, y, Keyword.get(bool_filters, x, z))
    end)
  end

  @doc """
  Apply range filters to the specified query.
  """
  def range_filters(%Ecto.Query{} = query, nil), do: range_filters(query, [])
  def range_filters(%Ecto.Query{} = query, range_filters) when range_filters == [], do: query

  def range_filters(%Ecto.Query{} = query, range_filters) do
    Enum.reduce(range_filters, query, fn x, acc -> Utils.Filters.apply(acc, x) end)
  end

  @doc """
  boolean filter timestamp:
  Allows filtering the base_query on a Timestamp field as though it were a boolean.
  For example, you could filter UserTask's on the completed_at timestamp field to produce
  queries which would give you Completed UserTask's and Not Completed UserTask's.
  Timestamps allow us to indicate not only WHEN an event happened, but also IF it has happened,
  thus, we need to allow for filtering based on IF this timestamp is set.
  """
  def b_timestamp_filter(base_query, field_name, argument_value)

  def b_timestamp_filter(%Ecto.Query{} = base_query, field_name, true) do
    from(x in base_query, where: not is_nil(field(x, ^field_name)))
  end

  def b_timestamp_filter(%Ecto.Query{} = base_query, field_name, false) do
    from(x in base_query, where: is_nil(field(x, ^field_name)))
  end

  @doc """
  Return a collection of records based on an attribute being passed a List of ID's
  """
  def bulk_query(base_query, bulk, restrict_fun) do
    Enum.reduce(bulk, %Ecto.Query{} = base_query, fn x, acc ->
      bulk_inclusion(acc, x, restrict_fun)
    end)
  end

  def bulk_inclusion(%Ecto.Query{} = query, {bulk_column, bulk_list} = _tuple, restrict_fun) do
    case restrict_fun.() do
      nil ->
        from(t in query, or_where: field(t, ^bulk_column) in ^bulk_list)

      {field_name, field_value} ->
        from(t in query,
          or_where: field(t, ^bulk_column) in ^bulk_list and field(t, ^field_name) == ^field_value
        )
    end
  end
end
