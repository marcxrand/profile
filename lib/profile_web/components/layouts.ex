defmodule ProfileWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ProfileWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="flex gap-3 h-13 pt-4 px-4 sm:px-6 lg:px-8">
      <a href="/" class="flex flex-none items-center">
        <.icon name="remix-user-4" class="size-7" />
      </a>
      <div class="border border-black/16 cursor-pointer flex flex-1 gap-1 items-center px-2 rounded text-black/40 text-sm hover:border-black/32">
        <.icon name="remix-search" class="size-3.25" /> Search
      </div>
      <.button class="px-4" href="/">
        <.icon name="remix-user-follow" /> Follow
      </.button>
    </header>
    <main>
      {render_slot(@inner_block)}
    </main>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="motion-safe:animate-spin ml-1 size-3" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="motion-safe:animate-spin ml-1 size-3" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="bg-base-300 border-2 border-base-300 card flex flex-row items-center relative rounded-full">
      <div class="absolute bg-base-100 border-1 border-base-200 brightness-200 h-full left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 rounded-full transition-[left] w-1/3" />

      <button
        class="cursor-pointer flex p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="opacity-75 size-4 hover:opacity-100" />
      </button>

      <button
        class="cursor-pointer flex p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="opacity-75 size-4 hover:opacity-100" />
      </button>

      <button
        class="cursor-pointer flex p-2 w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="opacity-75 size-4 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
