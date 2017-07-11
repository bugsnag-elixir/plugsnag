defmodule Plugsnag.ErrorReport do
  @moduledoc """
  A Plugsnag error report
  """

  @type t ::  %__MODULE__{
    severity: String.t | nil,
    context: String.t | nil,
    custom_grouping_hash: String.t | nil,
    metadata: map() | nil,
    user: map() | nil
  }

  defstruct [:severity, :context, :custom_grouping_hash, :metadata, :user]
end
