defmodule Plugsnag.ErrorReportBuilder do

  @callback build_error_report(Plugsnag.ErrorReport.t, Plug.Conn.t) :: Plugsnag.ErrorReport.t
end
