defmodule Plugsnag do
  use Plug.Builder

  def init(opts), do: opts

  def call(conn, opts) do
    try do
      super(conn, opts)
    rescue
      exception ->
        # FIXME: Turn this into a macro or function.
        stacktrace = System.stacktrace
        Bugsnag.report exception, stacktrace
        reraise exception, stacktrace
    end
  end
end
