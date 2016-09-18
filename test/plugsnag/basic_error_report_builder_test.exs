defmodule Plugsnag.BasicErrorReportBuilderTest do
  use ExUnit.Case
  use Plug.Test

  alias Plugsnag.BasicErrorReportBuilder
  alias Plugsnag.ErrorReport

  test "build_error_report/3 adds the appropriate fields to the error report" do
    conn = conn(:get, "/?hello=computer")

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("x-user-id", "abc123")

    error_report = BasicErrorReportBuilder.build_error_report(
      %ErrorReport{}, conn
    )


    assert error_report == %ErrorReport{
      metadata: %{
        request: %{
          request_path: "/",
          method: "GET",
          port: 80,
          scheme: :http,
          query_string: "hello=computer",
          params: %{"hello" => "computer"},
          headers: %{
            "accept" => "application/json",
            "x-user-id" => "abc123"
          }
        }
      }
    }
  end

  test "filters the params defined in config" do
    Application.put_env(:plugsnag, :filter_parameters, ~w(password receipt))

    conn = conn(:post, "/", %{"password" => "secret", "user" => "foo"})

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
      metadata: %{
        request: %{
          params: %{"password" => "[FILTERED]", "user" => "foo"}
        }
      }
    } = error_report
  end

end
