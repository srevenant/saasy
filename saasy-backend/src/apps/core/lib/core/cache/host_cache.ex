defmodule Core.HostCache do
  use MyLazyCache, bucket_key: :hcache_bucket, keyset_key: :hcache_keyset
end
