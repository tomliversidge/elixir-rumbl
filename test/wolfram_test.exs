defmodule Rumbl.WolframTest do
  use ExUnit.Case, async: true
  alias Rumbl.InfoSys.Wolfram

  test "makes request, reports results, then terminates" do
    ref = make_ref()
    {:ok, pid} = Wolfram.start_link("1 + 1", ref, self(), 1)
    Process.monitor(pid)
    assert_receive {:results, ^ref, [%Rumbl.InfoSys.Result{text: "2"}]}, 2500, :assert_receive_timeout
    assert_receive {:DOWN, _ref, :process, ^pid, :normal}
  end

  test "no query results reports an empty list" do
    ref = make_ref()
    {:ok, _} = Wolfram.start_link("none", ref, self(), 1)
    assert_receive {:results, ^ref, []}, 2500, :assert_receive_timeout
  end
end
