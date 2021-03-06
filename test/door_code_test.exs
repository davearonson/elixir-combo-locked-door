defmodule DoorCodeTest do
  use ExUnit.Case
  @code [1, 2, 3]
  @open_time 100

  test "happy path" do
    # We start a door, telling it its code, initializing the remaining digits to
    # be pressed, and how long to remain unlocked.
    {:ok, door} = Door.start_link({@code, @code, @open_time})
    # Verify that it starts out locked
    assert Door.get_state(door) == :locked
    door |> Door.press(1)
    assert Door.get_state(door) == :locked
    door |> Door.press(2)
    assert Door.get_state(door) == :locked
    door |> Door.press(3)
    # Verify that it is unlocked after the correct code is entered
    assert Door.get_state(door) == :open
    :timer.sleep(@open_time)
    # Verify that it is locked again after the specified time
    assert Door.get_state(door) == :locked
  end

  test "button press while unlocked resets timeout" do
    {:ok, door} = Door.start_link({@code, @code, @open_time})
    assert Door.get_state(door) == :locked
    @code |> Enum.each(&(Door.press(door, &1)))

    # sleep half the timeout
    :timer.sleep div(@open_time, 2)

    # digit press while unlocked, does nothing but resets timeout
    Door.press(door, 4)
    # verify that it is STILL unlocked
    assert Door.get_state(door) == :open

    # sleep half the timeout again and
    # verify that it is STILL unlocked;
    # we still have half a timeout to go!
    :timer.sleep div(@open_time, 2)
    assert Door.get_state(door) == :open

    # sleep half the timeout again,
    # and now it should finally be locked
    :timer.sleep div(@open_time, 2)
    assert Door.get_state(door) == :locked
  end

end
