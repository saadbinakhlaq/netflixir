defmodule Netflixir do
  @moduledoc """
  Documentation for Netflixir.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Netflixir.hello()
      :world

  """
  def hello do
    :world
  end

  @main_website "https://www.flixwatch.co/"
  def countries do
    case HTTPoison.get(@main_website) do
    { :ok, %HTTPoison.Response{ status_code: 200, body: body } } -> 
      urls =
        body
        |> Floki.find("div.widget_siteorigin-panels-postloop > p > a")
        |> Floki.attribute("href")
      { :ok, urls }
    {:ok, %HTTPoison.Response{status_code: 404}} ->
      IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
    end
  end

  @catalog_link "https://www.flixwatch.co/catalogs/"
  def country_catalog(url) do
    url
    |> String.split("/")
    |> Enum.at(-2)
    |> (&(@catalog_link <> "netflix" <> "-" <> &1 <> "/")).()
  end

  def total_pages(url) do
    case HTTPoison.get(url) do
    { :ok, %HTTPoison.Response{ status_code: 200, body: body } } ->
      body
      |> Floki.find(".pt-cv-pagination")
      |> Floki.attribute("data-totalpages")
      |> Enum.at(0)
      |> String.to_integer
      |> (&(1..&1)).()
      |> Enum.map(fn x ->
        url <> "?_page=" <> Integer.to_string(x)
      end)
    {:ok, %HTTPoison.Response{status_code: 404}} ->
      IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
    end
  end

  def movies(url) do
    IO.puts url
    case HTTPoison.get(url) do
    { :ok, %HTTPoison.Response{ status_code: 200, body: body } } ->
      body
      |> Floki.find(".pt-cv-ifield > a")
      |> Floki.attribute("href")
    {:ok, %HTTPoison.Response{status_code: 404}} ->
      IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
    end
  end

  def link_data(hyperlink) do
    hyperlink
    |> Enum.map(fn x ->
      %{ name: Floki.text(x), link: Floki.attribute(x, "href") }
    end)
  end

  def movie(url) do
    case HTTPoison.get(url) do
    { :ok, %HTTPoison.Response{ status_code: 200, body: body } } ->
      data = %{}
      title = body
      |> Floki.find(".entry-title")
      |> Floki.text
      data = Map.put(data, :title, title)

      plot = body
      |> Floki.find("#content_load_test")
      |> Floki.text
      data = Map.put(data, :plot, plot)

      main_content = body
      |> Floki.find("#main > p")

      streaming_countries = main_content
      |> Enum.at(1)
      |> Floki.find("a")
      |> link_data
      data = Map.put(data, :streaming_countries, streaming_countries)

      netflix_link = body
      |> Floki.find("#Netflix")
      |> Floki.attribute("href")
      |> Enum.at(0)
      data = Map.put(data, :netflix_link, netflix_link)

      audio = body
      |> Floki.find("#grid-single-main > div")
      |> Enum.at(1)
      |> Floki.find("p")
      |> Enum.at(0)
      |> Floki.text
      data = Map.put(data, :audio, audio)

      year = body
      |> Floki.find("#grid-single-main > div")
      |> Enum.at(1)
      |> Floki.find("p")
      |> Enum.at(1)
      |> Floki.text
      data = Map.put(data, :year, year)

      duration = body
      |> Floki.find("#grid-single-main > div")
      |> Enum.at(1)
      |> Floki.find("p")
      |> Enum.at(2)
      |> Floki.text
      data = Map.put(data, :duration, duration)

      rating = body
      |> Floki.find("#grid-single-rating > div")
      |> Enum.at(1)
      |> Floki.find("img")
      |> Floki.attribute("alt")
      |> Enum.at(0)
      data = Map.put(data, :rating, rating)

      actors = body
      |> Floki.find("#main")
      |> Floki.find("p")
      |> Enum.at(8)
      |> Floki.find("a")
      |> link_data
      data = Map.put(data, :actors, actors)

      directors = body
      |> Floki.find("#main")
      |> Floki.find("p")
      |> Enum.at(9)
      |> Floki.find("a")
      |> link_data
      data = Map.put(data, :directors, directors)

      genres = body
      |> Floki.find("#main")
      |> Floki.find("p")
      |> Enum.at(10) |> Floki.text
      Map.put(data, :genres, genres)

      alt_genres = body
      |> Floki.find("#main")
      |> Floki.find("p")
      |> Enum.at(11) |> Floki.text
      Map.put(data, :alt_genres, alt_genres)

    {:ok, %HTTPoison.Response{status_code: 404}} ->
      IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
    end
  end
end
