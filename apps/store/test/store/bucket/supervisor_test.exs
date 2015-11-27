defmodule Forwarder do
   use GenEvent

   def handle_event(event, parent) do
     send parent, event
     {:ok, parent}
   end
 end

defmodule Store.Bucket.SupervisorTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, sup} = Store.Bucket.Supervisor.start_link
    {:ok, sup: sup}
  end

  test "start_bucket: creates bucket", %{sup: sup} do
    assert {:ok, _bucket} = Store.Bucket.Supervisor.start_bucket(sup)
  end

  test "doesn't recreate buckets", %{sup: sup} do
    {:ok, bucket}   = Store.Bucket.Supervisor.start_bucket(sup)

    mon = Process.monitor(bucket)
    Process.exit(bucket, :shutdown)
    assert_receive {:DOWN, ^mon, _type, ^bucket, :shutdown}

    assert %{active: 0} = Supervisor.count_children(sup)
  end
end
