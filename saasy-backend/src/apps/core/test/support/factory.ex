defmodule Core.Test.Factory do
  use ExMachina.Ecto, repo: Core.Repo
  use Core.ContextClient

  use Core.Test.{
    SaasyFactory,
    UploadFactory
  }
end
