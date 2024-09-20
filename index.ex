defmodule LifeHogWeb.EventLive.Index do
  use LifeHogWeb, :live_view
  use LifeHogNative, :live_view
  require Logger  # 确保这行在文件的顶部

  alias LifeHog.Context
  alias LifeHog.Context.Event

  @impl true
  def mount(params, _session, socket) do


    interface = params["_interface"] || %{}
    time_zone = get_device_time_zone(interface)

    # Logger.info("Connected mount - 完整的 params 数据: #{inspect(params)}")
    # Logger.info("Connected mount - 提取的时区: #{inspect(time_zone)}")


    today = Date.utc_today()
    events = Context.list_events()
    filtered_events = filter_events_by_date(events, today)
    event_counts = calculate_event_counts(events)

      # 初始化 date_form
    date_form = to_form(%{"selected_date" => today}, as: "date")


    {:ok, assign(socket,
    events: events,
      filtered_events: filtered_events,
      event_counts: event_counts,
      selected_date: today,
      form: to_form(%{}, as: "event"),
      time_zone: time_zone , # 保存时区信息到 socket
      date_form: date_form  # 添加 date_form 到 assigns

    )}
  end

  defp get_device_time_zone(interface) do
    case interface do
      %{"i18n" => %{"time_zone" => tz}} when is_binary(tz) and tz != "" ->
        # Logger.info("成功从 interface 中获取时区: #{tz}")
        tz
      _ ->
        Logger.warning("无法从 interface 中获取时区，使用默认值 UTC", [])
        "Etc/UTC"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Events
      <:actions>
        <.link patch={~p"/events/"}>
          <.button>New Event</.button>
        </.link>
      </:actions>
    </.header>

    <.table id="events" rows={@events}>
  <:col :let={event} label="Name">
    <.link navigate={~p"/events/#{event.name}"}>
      <%= event.name %>
    </.link>
  </:col>
  <:col :let={event} label="Date"><%= event.date %></:col>
  <:col :let={event} label="Extra"><%= event.extra %></:col>
  <:action :let={event}>
    <div class="sr-only">
      <.link navigate={~p"/events/#{event.name}"}>Show</.link>
    </div>
    <.link patch={~p"/events/#{event}/edit"}>Edit</.link>
  </:action>
  <:action :let={event}>
    <.link
      phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{event.id}")}
      data-confirm="Are you sure?"
    >
      Delete
    </.link>
  </:action>
</.table>
    """
  end

  defp calculate_event_counts(events) do
    events
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {name, events} -> %{name: name, total_count: length(events)} end)
    |> Enum.sort_by(& &1.total_count, :desc)
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Context.get_event!(id)
    {:ok, _} = Context.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_event("update_date", %{"value" => date_string}, socket) do
    # 直接使用日期字符串，不进行解析
    form = to_form(%{socket.assigns.form.params | "date" => date_string}, as: "event")
    {:noreply, assign(socket, form: form, selected_date: date_string)}
  end

  @impl true
  def handle_event("submit", %{"event" => event_params}, socket) do
    Logger.info("Submitting event: #{inspect(event_params)}")

    event_params = process_date(event_params, socket.assigns.time_zone)
    Logger.info("Processed event params: #{inspect(event_params)}")

    case Context.create_event(event_params) do
      {:ok, event} ->
        Logger.info("Event created successfully: #{inspect(event)}")
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> update_assigns()}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Failed to create event: #{inspect(changeset)}")
        {:noreply, assign(socket, form: to_form(changeset, as: "event"))}
    end
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    # 确保包含选择的日期
    event_params = Map.put(event_params, "date", Date.to_iso8601(socket.assigns.selected_date))

    changeset =
      %Event{}
      |> Event.changeset(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "event"))}
  end

  @impl true
  def handle_event("delete_event", %{"id" => id}, socket) do
    event = Context.get_event!(id)
    {:ok, _} = Context.delete_event(event)

    {:noreply,
     socket
     |> put_flash(:info, "Event deleted successfully")
     |> update_assigns()}
  end

 @impl true
  def handle_event("change_date", %{"date" => %{"selected_date" => date_string}}, socket) do
    Logger.info("change_date: #{inspect(date_string)}")

    processed_params = process_date(%{"date" => date_string}, socket.assigns.time_zone)

    case processed_params["date"] do
      %Date{} = date ->
        {:noreply, socket |> assign(selected_date: date) |> update_assigns()}
      _ ->
        Logger.error("Invalid date format after processing: #{inspect(processed_params["date"])}")
        {:noreply, socket}
    end
  end


  @impl true
  def handle_event("previous_date", _, socket) do
    new_date = Date.add(socket.assigns.selected_date, -1)
    {:noreply, socket |> assign(selected_date: new_date) |> update_assigns()}
  end

  @impl true
  def handle_event("next_date", _, socket) do
    new_date = Date.add(socket.assigns.selected_date, 1)
    {:noreply, socket |> assign(selected_date: new_date) |> update_assigns()}
  end

  # 处理日期参数 转换时间为本地时区
  defp process_date(params, time_zone) do
    case params["date"] do
      nil -> params
      date_string ->
        case DateTime.from_iso8601(date_string) do
          {:ok, utc_datetime, _} ->
            local_datetime = DateTime.shift_zone!(utc_datetime, time_zone)
            local_date = DateTime.to_date(local_datetime)
            Logger.info("转换后的本地日期: #{inspect(local_date)}")
            Map.put(params, "date", local_date)
          {:error, reason} ->
            Logger.error("日期解析错误: #{inspect(reason)}")
            params
        end
    end
  end

  defp filter_events_by_date(events, date) do
    Enum.filter(events, fn event -> Date.compare(event.date, date) == :eq end)
  end

  defp update_assigns(socket) do
    events = Context.list_events()
    filtered_events = filter_events_by_date(events, socket.assigns.selected_date)
    event_counts = calculate_event_counts(events)
    assign(socket,
      events: events,
      filtered_events: filtered_events,
      event_counts: event_counts,
      selected_date: socket.assigns.selected_date,  # 确保 selected_date 被保留
      form: to_form(%{}, as: "event"),
      date_form: to_form(%{"selected_date" => socket.assigns.selected_date}, as: "date")

    )
  end


  @impl true
  def handle_event("show_event_details", %{"name" => name}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/events/#{name}")}
  end


end
