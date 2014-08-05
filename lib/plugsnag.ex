defmodule Plugsnag do
  @behaviour Plug.Wrapper

  def init(opts), do: opts

  def wrap(conn, opts, func) do
    try do
      func.(conn)
    rescue
      exception ->
        stacktrace = System.stacktrace
        Bugsnag.report exception, stacktrace
        reraise exception, stacktrace
    end
  end
end
