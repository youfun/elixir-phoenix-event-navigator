defmodule LifeHogWeb.EventLive.Index.SwiftUI do
  use LifeHogNative, [:render_component, format: :swiftui]

  def render(assigns, %{"target" => "ios"}) do
    ~LVN"""
    <ZStack>
      <Color color="systemBackground" ignoresSafeArea={true} />
      <VStack spacing={0}>
        <ScrollView>
          <VStack spacing={20} alignment="leading" style="padding(.horizontal, 16)">
            <Text style="font(.largeTitle);fontWeight(.bold)">事件管理</Text>
          <VStack alignment="leading" spacing={16} style="padding(.vertical, 16)">
            <Text style="font(.headline)">添加新事件</Text>
            <.form for={@form} id="form" phx-submit="submit" phx-change="validate">
              <VStack spacing={12} alignment="leading" style="frame(maxWidth: .infinity)">
                <.input field={@form[:name]} type="TextField" style="frame(maxWidth: .infinity)" placeholder="事件名称" />
                <.input
                  field={@form[:date]}
                  type="DatePicker"
                  selection={@form[:date].value || @selected_date |> Date.to_iso8601()}
                  displayedComponents={"date"}
                  style="frame(maxWidth: .infinity)"
                />
                <.button type="submit" style="frame(maxWidth: .infinity);padding(.vertical, 12)">
                 添加事件
                </.button>
              </VStack>
            </.form>
          </VStack>

            <Divider />

            <VStack alignment="leading" spacing={10} style="padding(20);background(.secondarySystemBackground);cornerRadius(10)">
              <Text style="font(.headline)">Eventlist</Text>
              <HStack spacing={12}>
                <.button phx-click="previous_date" style="padding(.horizontal, 10);padding(.vertical, 5)">
                  previous
                </.button>
              <.form for={@date_form} id="date-form" phx-change="change_date">
              <.input
                field={@date_form[:selected_date]}
                type="DatePicker"
                selection={@date_form[:selected_date].value || @selected_date |> Date.to_iso8601()}
                displayedComponents={"date"}

              />
              </.form>


                <.button phx-click="next_date" style="padding(.horizontal, 10);padding(.vertical, 5)">
                  next
                </.button>
              </HStack>


              <Text>当前选择日期: <%= @selected_date %></Text>
              <Text>过滤后的事件数量: <%= length(@filtered_events) %></Text>
              <List style="frame(height: 200)" phx-update="replace" id="events-list-#{@selected_date}">
                <%= for event <- @filtered_events do %>
              <HStack spacing={10} alignment="center" style="padding(.vertical, 8)" id={"event-#{event.id}"} key={"event-row-#{event.id}-#{@selected_date}"}>
              <VStack alignment="leading" spacing={4}>
                <Text style="font(.body);fontWeight(.semibold)"><%= event.name %></Text>
                <Text style="font(.caption);foregroundStyle(.secondary)"><%= event.date %></Text>
              </VStack>
              <Spacer />
              <.button phx-click="delete_event" phx-value-id={event.id} style="padding(.horizontal, 10);padding(.vertical, 5);cornerRadius(5)">
                <Text style="font(.caption);foregroundColor(.white)">删除</Text>
              </.button>
            </HStack>
          <% end %>
        </List>

            </VStack>

            <Divider />

            <VStack alignment="leading" spacing={10} style="padding(20);background(.secondarySystemBackground);cornerRadius(10)">
              <Text style="font(.headline)">统计</Text>
              <Table style="frame(height: 200)">
                <Group template={:columns}>
                  <TableColumn id="name">事件名称</TableColumn>
                  <TableColumn id="count">次数</TableColumn>
                </Group>
                <Group template={:rows}>
                  <%= for item <- @event_counts do %>
                    <TableRow id={item.name}>
                      <Text><%= item.name %></Text>
                      <Text>累计 <%= item.total_count %> 次</Text>
                    </TableRow>
                  <% end %>
                </Group>
              </Table>
            </VStack>
          </VStack>
        </ScrollView>

        <Divider />

        <HStack spacing={0} alignment="center" style="frame(height: 50);background(.systemBackground)">
          <Spacer />
          <VStack spacing={4} alignment="center" style="frame(width: 80)">
            <Image systemName="calendar" style="font(.system(size: 20));foregroundColor(.blue)" />
            <Text style="font(.caption);foregroundColor(.blue)">事件</Text>
          </VStack>
          <Spacer />
          <VStack spacing={4} alignment="center" style="frame(width: 80)">
            <Image systemName="chart.bar" style="font(.system(size: 20));foregroundColor(.gray)" />
            <Text style="font(.caption);foregroundColor(.gray)">统计</Text>
          </VStack>
          <Spacer />
          <VStack spacing={4} alignment="center" style="frame(width: 80)">
            <Image systemName="gear" style="font(.system(size: 20));foregroundColor(.gray)" />
            <Text style="font(.caption);foregroundColor(.gray)">设置</Text>
          </VStack>
          <Spacer />
        </HStack>
      </VStack>
    </ZStack>
    """
  end

  def render(assigns, _interface) do
    ~LVN"""
    <ZStack>
      <Color color="systemBackground" ignoresSafeArea={true} />
      <VStack spacing={0}>
        <ScrollView>
          <VStack spacing={20} alignment="leading" style="padding(.all, 20)">
            <Text style="font(.largeTitle);fontWeight(.bold)">事件管理</Text>

            <VStack alignment="leading" spacing={10} style="padding(20);background(.secondarySystemBackground);cornerRadius(10)">
              <Text style="font(.headline)">添加新事件</Text>
              <.simple_form for={@form} id="form" phx-submit="submit" phx-change="validate">
                <HStack spacing={10} alignment="firstTextBaseline">
                  <.input field={@form[:name]} type="TextField" style="frame(width: 200)" placeholder="事件名称" />
                  <.input
                    field={@form[:date]}
                    type="DatePicker"
                    selection={@form[:date].value || @selected_date |> Date.to_iso8601()}
                    displayedComponents={"date"}
                    phx-change="update_date"
                    style="frame(width: 250)"
                    in="local"
                    timeZone="local"
                  />
                  <.button type="submit" style="frame(width: 100);padding(.vertical, 10)">
                    添加事件
                  </.button>
                </HStack>
              </.simple_form>
            </VStack>

            <Divider />

            <VStack alignment="leading" spacing={10} style="padding(20);background(.secondarySystemBackground);cornerRadius(10)">
              <Text style="font(.headline)">Event list</Text>
              <HStack spacing={12}>
                <Button phx-click="previous_date">
                  <Text>previous</Text>
                </Button>
              <.simple_form for={@date_form} id="date-form" phx-change="change_date">
              <.input
                field={@date_form[:selected_date]}
                type="DatePicker"
                selection={@selected_date |> Date.to_iso8601()}
                displayedComponents={"date"}
                style="frame(width: 250)"

              />
            </.simple_form>

                <Button phx-click="next_date">
                  <Text>next</Text>
                </Button>
              </HStack>
             <List style="frame(height: 200)" phx-update="replace" id="events-list-#{@selected_date}">
                <%= for event <- @filtered_events do %>
              <HStack spacing={10} alignment="center" style="padding(.vertical, 8)" id={"event-#{event.id}"} key={"event-row-#{event.id}-#{@selected_date}"}>
              <VStack alignment="leading" spacing={4}>
                <Text style="font(.body);fontWeight(.semibold)"><%= event.name %></Text>
                <Text style="font(.caption);foregroundStyle(.secondary)"><%= event.date %></Text>
              </VStack>
              <Spacer />
              <.button phx-click="delete_event" phx-value-id={event.id} style="padding(.horizontal, 10);padding(.vertical, 5);cornerRadius(5)">
                <Text style="font(.caption);foregroundColor(.white)">删除</Text>
              </.button>
            </HStack>
          <% end %>
        </List>
            </VStack>

            <Divider />

            <VStack alignment="leading" spacing={10} style="padding(20);background(.secondarySystemBackground);cornerRadius(10)">
              <Text style="font(.headline)">统计</Text>
              <List style="frame(height: 200)">
                <%= for item <- @event_counts do %>
                  <NavigationLink destination={~p"/events/#{item.name}"}>
                    <HStack spacing={10} style="padding(.vertical, 8)">
                      <Text style="font(.body);foregroundStyle(.primary)"><%= item.name %></Text>
                      <Spacer />
                      <Text style="font(.body);foregroundStyle(.secondary)">共计 <%= item.total_count %> 次</Text>
                    </HStack>
                  </NavigationLink>
                <% end %>
              </List>
            </VStack>
          </VStack>
        </ScrollView>

        <Divider />

        <HStack spacing={0} alignment="center" style="frame(height: 50);background(.systemBackground)">
          <Spacer />
          <NavigationLink destination={~p"/"}>
            <VStack spacing={4} alignment="center" style="frame(width: 80)">
              <Image systemName="calendar" style="font(.system(size: 20));foregroundColor(.blue)" />
              <Text style="font(.caption);foregroundColor(.blue)">事件</Text>
            </VStack>
          </NavigationLink>
          <Spacer />
          <VStack spacing={4} alignment="center" style="frame(width: 80)">
            <Image systemName="chart.bar" style="font(.system(size: 20));foregroundColor(.gray)" />
            <Text style="font(.caption);foregroundColor(.gray)">统计</Text>
          </VStack>
          <Spacer />
          <NavigationLink destination={~p"/about"}>
            <VStack spacing={4} alignment="center" style="frame(width: 80)">
              <Image systemName="gear" style="font(.system(size: 20));foregroundColor(.gray)" />
              <Text style="font(.caption);foregroundColor(.gray)">设置</Text>
            </VStack>
          </NavigationLink>
          <Spacer />
        </HStack>
      </VStack>
    </ZStack>
    """
  end
end
