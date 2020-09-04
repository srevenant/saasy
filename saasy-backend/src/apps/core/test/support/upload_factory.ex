defmodule Core.Test.UploadFactory do
  use ExMachina.Ecto, repo: Core.Repo
  use Core.ContextClient

  defmacro __using__(_) do
    quote do
      ################################################################################
      def upload_file_factory do
        # project = insert(:project)
        user = insert(:user)

        %Upload.File{
          user: user,
          user_id: user.id,
          # project: project,
          type: :test,
          ref_id: Ecto.UUID.generate(),
          path: sequence("upload"),
          meta: %{},
          valid: false
        }
      end
    end
  end
end
