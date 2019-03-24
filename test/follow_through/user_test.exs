defmodule FollowThrough.UserTest do
  use FollowThrough.DataCase
  alias FollowThrough.Credential
  alias FollowThrough.User

  test "returns user if one already exists" do
    user = insert(:user)
    credential = insert(:credential, user: user)

    expected = {{:ok, user}, :existing}

    actual =
      User.find_or_create(%{uid: credential.uid, provider: String.to_atom(credential.provider)})

    assert expected == actual
  end

  test "creates a new user and credential if they aren't found" do
    expected_name = "New User"
    expected_email = "email@example.com"
    expected_image = "https:avatar.example.com/avatar"
    expected_provider = "github"
    expected_uid = "newuid"

    auth = %{
      uid: expected_uid,
      provider: :github,
      info: %{
        name: expected_name,
        email: expected_email,
        image: expected_image
      }
    }

    actual = User.find_or_create(auth)

    assert {{:ok,
             %User{
               name: ^expected_name,
               email: ^expected_email,
               avatar: ^expected_image,
               credentials: [%Credential{provider: ^expected_provider, uid: ^expected_uid}]
             }}, :new} = actual
  end

  test "returns an error if the user could not be created" do
    actual =
      User.find_or_create(%{uid: "", provider: :atom, info: %{name: "", email: "", image: ""}})

    assert {{:error, %Ecto.Changeset{}}, :new} = actual
  end
end
