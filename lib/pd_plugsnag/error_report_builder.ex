defmodule PdPlugsnag.ErrorReportBuilder do

  @callback build_error_report(PdPlugsnag.ErrorReport.t, Plug.Conn.t) :: PdPlugsnag.ErrorReport.t
end
