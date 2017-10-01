defmodule Xema.Float do
  @moduledoc """
  TODO: rewrite
  This module contains the keywords and validation functions for a `float`
  schema.

  Supported keywords:
  * `minimum` specifies a minimum numeric value.
  * `maximum` specifies a maximum numeric value.
  * `exclusive_minimum` is a boolean. When `true`, it indicates that the
    `minimum` excludes the value himself, i.e., x > min. When false (or not set)
    , it indicates that the `minimum` includes the value himself, i.e., x ≥ min.
  * `exclusive_maximum`
  * `multiple_of` restrict the value to a multiple of the given number.
  * `enum` specifies an enumeration.

  `as` can be an atom that will be report in an error case as type of the
  schema. Default of `as` is `:float`

  ## Examples

      iex> import Xema
      Xema
      iex> float = xema :float, minimum: 2.3, as: :frac
      %Xema{
        keywords: %Xema.Float{
          as: :frac,
          enum: nil,
          exclusive_maximum: nil,
          exclusive_minimum: nil,
          maximum: nil,
          minimum: 2.3,
          multiple_of: nil
        },
        type: :float,
        id: nil,
        schema: nil,
        title: nil,
        description: nil,
        default: nil
      }
      iex> validate(float, 3.2)
      :ok
      iex> validate(float, 1.1)
      {:error, %{minimum: 2.3, reason: :too_small}}
      iex> validate(float, "foo")
      {:error, %{reason: :wrong_type, type: :frac}}

  """

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
    as: :float
  ]

  @type t :: %Xema.Float{
    minimum: integer | nil,
    maximum: integer | nil,
    exclusive_minimum: boolean | nil,
    exclusive_maximum: boolean | nil,
    multiple_of: number | nil,
    enum: list | nil,
    as: atom
  }
end
