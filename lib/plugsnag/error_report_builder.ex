defmodule Plugsnag.ErrorReportBuilder do

  @callback build_error_report(Plugsnag.ErrorReport.t, Plug.Conn.t) :: Plugsnag.ErrorReport.t
  @callback build_error_report(Plugsnag.ErrorReport.t, Plug.Conn.t, Exception.t) :: Plugsnag.ErrorReport.t

  @optional_callbacks build_error_report: 2, build_error_report: 3
end
