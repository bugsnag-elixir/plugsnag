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

    error_report =
      BasicErrorReportBuilder.build_error_report(
        %ErrorReport{},
        conn
      )

    assert error_report == %ErrorReport{
             metadata: %{
               request: %{
                 request_path: "/",
                 method: "GET",
                 url: "http://#{conn.host}/?hello=computer",
                 port: 80,
                 scheme: :http,
                 query_string: "hello=computer",
                 params: %{"hello" => "computer"},
                 headers: %{
                   "accept" => "application/json",
                   "x-user-id" => "abc123"
                 },
                 client_ip: "127.0.0.1"
               }
             }
           }
  end

  test "filters the params defined in config" do
    Application.put_env(:plugsnag, :filter, params: ~w(password receipt))

    conn = conn(:post, "/", %{"password" => "secret", "user" => "foo", "receipt" => "DATA"})

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
             metadata: %{
               request: %{
                 params: %{"password" => "[FILTERED]", "user" => "foo", "receipt" => "[FILTERED]"}
               }
             }
           } = error_report
  end

  test "filters the headers defined in config" do
    Application.put_env(:plugsnag, :filter, headers: ~w(Authorization))

    conn = conn(:post, "/", "") |> put_req_header("authorization", "Bearer SOMESECRETTOKEN")

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
             metadata: %{
               request: %{
                 headers: %{"authorization" => "[FILTERED]"}
               }
             }
           } = error_report
  end

  test "does not filter the query string parameters if :filter_query_string config option is not set" do
    Application.delete_env(:plugsnag, :filter_query_string)
    Application.put_env(:plugsnag, :filter, params: ~w(userId password receipt))

    conn = conn(:post, "/profile?userId=54321&foo=bar", "")

    expected_query_string =
      URI.encode_query(%{
        "userId" => "54321",
        "foo" => "bar"
      })

    expected_url = "http://www.example.com/profile?#{expected_query_string}"

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
             metadata: %{
               request: %{
                 params: %{
                   "userId" => "[FILTERED]",
                   "foo" => "bar"
                 },
                 query_string: ^expected_query_string,
                 url: ^expected_url
               }
             }
           } = error_report
  end

  test "does not filter the query string parameters if :filter_query_string config option is set to false" do
    Application.put_env(:plugsnag, :filter_query_string, false)
    Application.put_env(:plugsnag, :filter, params: ~w(userId password receipt))

    conn = conn(:post, "/profile?userId=54321&foo=bar", "")

    expected_query_string =
      URI.encode_query(%{
        "userId" => "54321",
        "foo" => "bar"
      })

    expected_url = "http://www.example.com/profile?#{expected_query_string}"

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
             metadata: %{
               request: %{
                 params: %{
                   "userId" => "[FILTERED]",
                   "foo" => "bar"
                 },
                 query_string: ^expected_query_string,
                 url: ^expected_url
               }
             }
           } = error_report
  end

  test "filters the query string parameters if :filter_query_string config option is true" do
    Application.put_env(:plugsnag, :filter_query_string, true)
    Application.put_env(:plugsnag, :filter, params: ~w(userId password receipt))

    conn = conn(:post, "/profile?userId=54321&foo=bar", "")

    expected_query_string =
      URI.encode_query(%{
        "userId" => "[FILTERED]",
        "foo" => "bar"
      })

    expected_url = "http://www.example.com/profile?#{expected_query_string}"

    error_report = BasicErrorReportBuilder.build_error_report(%ErrorReport{}, conn)

    assert %ErrorReport{
             metadata: %{
               request: %{
                 params: %{
                   "userId" => "[FILTERED]",
                   "foo" => "bar"
                 },
                 query_string: ^expected_query_string,
                 url: ^expected_url
               }
             }
           } = error_report
  end
end
