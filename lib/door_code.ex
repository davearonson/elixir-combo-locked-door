defmodule Door do
  use GenStateMachine

  ### Client API
  def start_link({code, remaining, unlock_time}) do
    # The GenStateMachine.start_link function takes the module to start and the
    # initial state as an argument.
    GenStateMachine.start_link(Door, {:locked, {code, remaining, unlock_time}})
  end

  def press(pid, digit) do
    GenStateMachine.cast(pid, {:press, digit})
  end

  def get_state(pid) do
    {state, _data} = :sys.get_state(pid)
    state
  end
  
  def get_time_left(pid) do
    {_state, {_code, _remaining, time_left} } = :sys.get_state(pid)
    time_left
  end
  
  ### Server API
  def handle_event(:cast, {:press, digit}, :open, state = {_, _, unlock_time}) do
    IO.puts "[#{digit}] pressed while already open.  Remaining unlocked for #{unlock_time}"
    {:next_state, :open, state, unlock_time}
  end
  ### Server API
  def handle_event(:cast, {:press, digit}, :open, state = {_, _, unlock_time}) do
    IO.puts "[#{digit}] pressed while already open.  Remaining unlocked for #{unlock_time}"
    {:next_state, :open, state, unlock_time}
  end

  def handle_event(:cast, {:press, digit}, :locked, {code, remaining, unlock_time}) do
    case remaining do
      [digit] ->
        IO.puts "[#{digit}] Correct code.  Unlocked for #{unlock_time}"
        {:next_state, :open, {code, code, unlock_time}, unlock_time}
      [digit|rest] ->
        IO.puts "[#{digit}] Correct digit but not yet complete."
        {:next_state, :locked, {code, rest, unlock_time}}
      _ ->
        IO.puts "[#{digit}] Wrong digit, locking."
        {:next_state, :locked, {code, code, unlock_time}}
    end
  end

  def handle_event(:timeout, _, _, data) do
    IO.puts "timeout expired, locking door"
    {:next_state, :locked, data}
  end
  
end
