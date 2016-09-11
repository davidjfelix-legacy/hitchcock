defmodule Hitchcock.Repo.Migrations.CreateDb do
  use Ecto.Migration

  def change do
    ### Groups
    create table(:groups, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false

      timestamps
    end

    # Groups use name as a changable identifier in the API
    create unique_index(:groups, [:name])


    ### Comments
    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :body, :text, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      timestamps
    end


    ### Comment Stream Comments
    create table(:comment_stream_comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :time, :integer, null

      add :comment_id, references(:comments, on_delete: :delete_all), null: false
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      timestamps
    end

    ### Group Permissions
    create table(:group_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :group_id, references(:group, on_delete: :delete_all), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false

      timestamps
    end

    # Prevent Bad data. No more than one group permission per permission
    create unique_index(:group_permissions, [:permission_id])


    ### Permissions
    create table(:permissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :grant, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps
    end

    # TODO: Add a constraint that holds permission into a fixed enum of values


    ### Users
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false

      timestamps
    end

    # Users use username as a changable identifier in the API
    create unique_index(:users, [:username])

    # Users must have unique emails to discourage multi-accounts
    create unique_index(:users, [:email])


    ### Videos
    create table(:videos) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :url, :string, null: false
      add :description, :text, null: false

      add :owner_id, references(:user, on_delete: :delete_all), null: false
      add :group_id, references(:group, on_delete: :delete_all), null: false

      timestamps
    end


    ### Video Permissions
    create table(:video_permissions, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :video_id, references(:video, on_delete: :delete_all), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false
    end

    # Prevent Bad data. No more than one video permission per permission
    create unique_index(:video_permissions, [:permission_id])

  end
end
