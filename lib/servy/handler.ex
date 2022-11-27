defmodule Servy.Handler do
  @moduledoc """
    Handle something
  """

  @about_page_path Path.expand("../../pages/",__DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  alias Servy.Conv

  @doc "desc about the function"
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
    |> parse
    |> log
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end


  # def route(%Conv{} = conv) do
  #   # conv = %{ method: "GET", path: "/sompath", resp_body: "Hello ,this is body content."}

  #   # %{conv | resp_body: "Hello, this is the content."}
  #   route(conv, conv.method, conv.path)
  # end

  def route(%Conv{ method: "GET", path: "/about"} = conv) do
    @about_page_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end
  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end
  def handle_file({:error, enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found."}
  end
  def handle_file({:error, message}, conv) do
    %{conv | status: 500, resp_body: "File error:#{message}"}
  end
  # def route(conv, "GET", "/about") do
  #   file = Path.expand("../../pages/",__DIR__) |> Path.join("about.html")
  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}
  #     {:error, enoent} ->
  #         %{conv | status: 404, resp_body: "File not found."}
  #     {:error, message} ->
  #       %{conv | status: 500, resp_body: "File error:#{message}"}
  #   end
  # end

  def route(%Conv{ method: "GET", path: "/hello"} = conv) do
    %{conv | status: 200, resp_body: "Wellcome to Elixir world."}
  end

  def route(%Conv{ method: "GET", path: "/book"} = conv) do
    %{conv | status: 200, resp_body: "Elixir In Action, Elixir CookBook"}
  end

  def route(%Conv{ method: "GET", path: "/book/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Elixir In Action #{id}" }
  end

  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    %{conv | status: 201, resp_body: "Create a  #{conv.params["type"]} bear named #{conv.params["name"]}! " }
  end

  def route(%Conv{ path: path } = conv) do
    %{conv | status: 404, resp_body: "#{conv.path} is not found."}
  end



  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # private function inside module
  # defp status_reason(code) do
  #   %{
  #     200 => "OK",
  #     201 => "Created",
  #     401 => "Unauthorized",
  #     403 => "Forbidden",
  #     404 => "Not Found",
  #     500 => "Internal Server Error"
  #   }[code]
  # end


  def test() do
    IO.puts "====== test is running ======"
    request2 = """
    POST /bears HTTP/1.1
    Host: example.com
    User-Agent: Macintash/chrome
    Accept: */*
    Content-Type: application/x-www-form-urlencoded


    name=hello&type=black
    """
    response2 = Servy.Handler.handle(request2)
    IO.puts response2
  end

end

# request = """
# GET /book/1 HTTP/1.1
# Host: example.com
# User-Agent:
# Accept: */*
# """

# response = Servy.Handler.handle(request)
# IO.puts response

request2 = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: Macintash/chrome
Accept: */*
Content-Type: application/x-www-form-urlencoded

name=hello&type=black
"""
response2 = Servy.Handler.handle(request2)
IO.puts response2

# request3 = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent:
# Accept: */*
# """
# response3 = Servy.Handler.handle(request3)
# IO.puts response3

# IO.puts "response4"