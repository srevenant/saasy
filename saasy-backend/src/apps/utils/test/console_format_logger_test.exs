defmodule Util.ConsoleFormatLoggerTest do
  use ExUnit.Case, async: true
  alias Util.ConsoleFormatLogger

  doctest Util.ConsoleFormatLogger

  @timestamp {{2014, 12, 30}, {12, 6, 30, 100}}

  describe "format/4" do
    test "outputs basic string message correctly" do
      expected = "2014-12-30 12:06:30.100 msg=\"basic string\"\n"
      logged = ConsoleFormatLogger.format(:info, "basic string", @timestamp, [])
      assert IO.iodata_to_binary(logged) == expected
    end

    test "outputs supported basic metadata correctly" do
      expected = "2014-12-30 12:06:30.100 msg=\"basic string\" uid=1 oid=4 type=test\n"

      logged =
        ConsoleFormatLogger.format(:info, "basic string", @timestamp, uid: 1, oid: 4, type: "test")

      assert IO.iodata_to_binary(logged) == expected
    end

    test "handles quoted message text" do
      expected = "2014-12-30 12:06:30.100 msg=\"text with \\\"escaped quotes\\\"\"\n"
      logged = ConsoleFormatLogger.format(:info, "text with \"escaped quotes\"", @timestamp, [])
      assert IO.iodata_to_binary(logged) == expected
    end

    test "handles message when given as a list" do
      expected = "2014-12-30 12:06:30.100 msg=\"some text that looks normal\"\n"

      logged =
        ConsoleFormatLogger.format(
          :info,
          ["some ", "text ", "that looks ", "normal"],
          @timestamp,
          []
        )

      assert IO.iodata_to_binary(logged) == expected
    end
  end

  describe "redact_sensitive/1" do
    test "removes DB credentials from messages" do
      raw = """
      2017-09-01 12:44:14.375 msg="Child DBConnection.Poolboy of
      Supervisor SharedDb.Repo started\nPid: #PID<0.1132.0>\nStart Call:
      :poolboy.start_link([name: {:local, SharedDb.Repo.Pool}, strategy: :fifo,
      size: 10, max_overflow: 0, worker_module: DBConnection.Poolboy.Worker],
      {Postgrex.Protocol, [types: Ecto.Adapters.Postgres.TypeModule, name:
      SharedDb.Repo.Pool, otp_app: :shared_db, repo: SharedDb.Repo, pool_size:
      10, timeout: 30000, adapter: Ecto.Adapters.Postgres, database:
      \"saasy_dev\", username: \"postgres\", password: \"\", hostname:
      \"localhost\", port: 5432, pool_timeout: 5000, pool_size: 10, timeout:
      30000, adapter: Ecto.Adapters.Postgres, database: \"saasy_dev\", username: \"postgres\", password: \"\", hostname: \"localhost\", pool:
      DBConnection.Poolboy]})\nRestart: :permanent\nShutdown: 5000\nType:
      :worker"
      """

      expected = """
      2017-09-01 12:44:14.375 msg="Child DBConnection.Poolboy of
      Supervisor SharedDb.Repo started\nPid: #PID<0.1132.0>\nStart Call:
      :poolboy.start_link([name: {:local, SharedDb.Repo.Pool}, strategy: :fifo,
      size: 10, max_overflow: 0, worker_module: DBConnection.Poolboy.Worker],
      {Postgrex.Protocol, [types: Ecto.Adapters.Postgres.TypeModule, name:
      SharedDb.Repo.Pool, otp_app: :shared_db, repo: SharedDb.Repo, pool_size:
      10, timeout: 30000, adapter: Ecto.Adapters.Postgres, database:
      \"saasy_dev\", hostname:
      \"localhost\", port: 5432, pool_timeout: 5000, pool_size: 10, timeout:
      30000, adapter: Ecto.Adapters.Postgres, database: \"saasy_dev\", hostname: \"localhost\", pool:
      DBConnection.Poolboy]})\nRestart: :permanent\nShutdown: 5000\nType:
      :worker"
      """

      output = ConsoleFormatLogger.redact_sensitive(raw)
      assert output == expected
    end

    test "removes postgres DB url from messages" do
      test =
        "url: \"postgres://pgadm:@saasy-p1.somewhere.us-west-2.rds.amazonaws.com:9999/saasy_p1\", more: true"

      output = ConsoleFormatLogger.redact_sensitive(test)
      assert output == "more: true"
    end

    test "removes multiple instances of username and password at different points" do
      test = "hello password: \"stuff\", Tom, your username: \"jim\" car is password: \"old\""
      output = ConsoleFormatLogger.redact_sensitive(test)
      assert output == "hello Tom, your car is "

      assert "" == ConsoleFormatLogger.redact_sensitive("username: \"393092s{dlkfjl()!@#$%^}\"")
    end

    test "removes password when formatting password change variables" do
      test = inspect(%{password: "sensitive", user_id: "1"})
      output = ConsoleFormatLogger.redact_sensitive(test)
      assert output == "%{user_id: \"1\"}"
    end
  end
end
