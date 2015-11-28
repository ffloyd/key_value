defmodule Store.RegistryTest do
  use ExUnit.Case

  setup do
    {:ok, bsup}     = Store.Bucket.Supervisor.start_link
    {:ok, manager}  = GenEvent.start_link
    GenEvent.add_mon_handler(manager, Forwarder, self)

    {:ok, registry} = Store.Registry.start_link(manager, bsup)
    {:ok, registry: registry}
  end

  test "lookup: return nil if bucket doesn't exists", %{registry: registry} do
    assert Store.Registry.lookup(registry, "bucket") == nil
  end

  test "lookup, create: can lookup created bucket", %{registry: registry} do
    assert {:ok, bucket} = Store.Registry.create(registry, "bucket")
    assert Store.Registry.lookup(registry, "bucket") == bucket
  end

  test "create: sends message to manager", %{registry: registry} do
    {:ok, bucket} = Store.Registry.create(registry, "bucket")
    assert_receive {:create, "bucket", ^bucket}
  end

  test "create: return :error if bucket already exists", %{registry: registry} do
    Store.Registry.create(registry, "bucket")
    assert Store.Registry.create(registry, "bucket") == :error
  end

  test "lookup: return nil for shutdowned bucket", %{registry: registry} do
    {:ok, bucket} = Store.Registry.create(registry, "bucket")
    Process.exit(bucket, :shutdown)
    assert_receive {:exit, "bucket", ^bucket}
    assert Store.Registry.lookup(registry, "bucket") == nil
  end
end
