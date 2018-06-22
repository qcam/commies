defmodule Commies.Factory do
  use ExMachina.Ecto, repo: Commies.Repo

  def user_factory() do
    %Commies.User{
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence(:name, &"user#{&1}"),
      auth_provider: "github",
      auth_user_id: sequence(:id, &to_string/1)
    }
  end

  def comment_factory() do
    %Commies.Comment{
      content: "Hello World"
    }
  end
end
