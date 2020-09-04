defmodule Core.RoleCache do
  use MyLazyCache, bucket_key: :rcache_bucket, keyset_key: :rcache_keyset
end
