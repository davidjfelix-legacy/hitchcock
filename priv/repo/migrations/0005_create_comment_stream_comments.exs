defmodule Hitchcock.Repo.Migrations.CreateCommentStreamComments do
  use Ecto.Migration

  def change do
    ### Comment Stream Comments
    create table(:comment_stream_comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :time, :integer, null: false

      add :comment_id, references(:comments, on_delete: :delete_all, type: :uuid), null: false

      timestamps
    end

    # TODO: add constraint to only allow positive time
  end
end
