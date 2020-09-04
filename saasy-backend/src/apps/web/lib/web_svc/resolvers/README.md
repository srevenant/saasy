pattern:

   resolve_{name} - methods directly called as resolvers.  Auth is assumed handled.
   query_{name} - GraphQL query endpoints
   mutate_{name}{_action} - GraphQL mutation endpoints

   {name} matches the respective field on the schema.
   {_action}, where it makes sense, is the action taken, such as:

       upsert
       delete

       No actions are included for lists (the query should be plural, however),
       nor for loading something (singular query).

Responses:

  - Direct GraphQL Result  {OBJECT} | nil
  - Result with metadata:

     {
       success: Boolean!
       reason: String      -- optional, if success=false
       meta: {json}        -- any additional data, such as 'total' and pagination
       result: {OBJECT}    -- as this is an object, unique result objects are
                              required for each query object
     }

    The generic status_result object should not be used to return full objects,
    as the result is only JSON, but it can be used for specific/focused things.
