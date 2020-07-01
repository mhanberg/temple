defmodule <%= inspect context.web_module %>.ModalComponent do
  use <%= inspect context.web_module %>, :live_component

  @impl true
  def render(assigns) do
    live_temple do
      div id: @id,
          class: "phx-modal",
          phx_capture_click: "close",
          phx_window_keydown: "close",
          phx_key: "escape",
          phx_target: "##{@id}",
          phx_page_loading: true do

        div class: "phx-modal-content" do
          live_patch raw("&times"), to: @return_to, class: "phx-modal-close"
          live_component @socket, @component, @opts
        end
      end
    end
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
