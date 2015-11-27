defmodule Store.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Store.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "get: return nil when no value for key", %{bucket: bucket} do
    assert Store.Bucket.get(bucket, "key") == nil
  end

  test "get, put: saves values and returns it", %{bucket: bucket} do
    assert Store.Bucket.put(bucket, "key", "value") == :ok
    assert Store.Bucket.get(bucket, "key") == "value"
  end

  test "delete: deletes value by key", %{bucket: bucket} do
    Store.Bucket.put(bucket, "key", "value")
    assert Store.Bucket.delete(bucket, "key") == :ok
    assert Store.Bucket.get(bucket, "key") == nil
  end

  test "delete: return :ok even if key doesn't exists", %{bucket: bucket} do
    assert Store.Bucket.delete(bucket, "key") == :ok
  end
end
