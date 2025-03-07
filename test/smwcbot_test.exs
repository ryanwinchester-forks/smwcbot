defmodule SMWCBotTest do
  use ExUnit.Case, async: true
  use Mimic

  import ExUnit.CaptureLog

  alias SMWCBot.HTMLBodies

  test "returns first result to user with 0 results" do
    chat = "mychat"
    sender = "user-mcface"

    expected_message = "Sorry #{sender}, no results"

    expect(Mojito, :get, fn _uri ->
      {:ok, %{status_code: 200, body: HTMLBodies.smwc_results(0)}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    assert :ok = SMWCBot.handle_message("!hack what the eff", sender, chat)
  end

  test "returns first result to user with 1 result" do
    chat = "mychat"
    sender = "user-mcface"

    expected_text = "Redeeming Peach"
    expected_href = "https://www.smwcentral.net/?p=section&a=details&id=10173"
    expected_message = "Here #{sender}, #{expected_text} @ #{expected_href}"

    expect(Mojito, :get, fn _uri ->
      {:ok, %{status_code: 200, body: HTMLBodies.smwc_results(1)}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    assert :ok = SMWCBot.handle_message("!hack redeeming peach", sender, chat)
  end

  test "returns first result to user with 2 results" do
    chat = "mychat"
    sender = "user-mcface"

    expected_text = "Fast Food Kaizo"
    expected_href = "https://www.smwcentral.net/?p=section&a=details&id=27706"
    expected_message = "Here #{sender}, #{expected_text} @ #{expected_href}"

    expect(Mojito, :get, fn _uri ->
      {:ok, %{status_code: 200, body: HTMLBodies.smwc_results(2)}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    assert :ok = SMWCBot.handle_message("!hack foo", sender, chat)
  end

  test "returns first result to user with multiple pages" do
    chat = "mychat"
    sender = "user-mcface"

    expected_text = "Mario Keymanship"
    expected_href = "https://www.smwcentral.net/?p=section&a=details&id=29650"
    expected_message = "Here #{sender}, #{expected_text} @ #{expected_href}"

    expect(Mojito, :get, fn _uri ->
      {:ok, %{status_code: 200, body: HTMLBodies.smwc_results("multi-page")}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
  end

  test "returns error when smwcentral.net returns a non-200 status code" do
    chat = "mychat"
    sender = "user-mcface"
    status_code = 404
    body = "Not found"

    expected_message = "Sorry #{sender}, bot can't complete that search: #{status_code}"

    expect(Mojito, :get, fn _uri ->
      {:ok, %{status_code: status_code, body: body}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    log =
      capture_log(fn ->
        assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
      end)

    assert log =~ "Error fetching page, status #{status_code}: \"#{body}\""
  end

  test "returns error when mojito returns an error" do
    chat = "mychat"
    sender = "user-mcface"
    error = "This is error"

    expected_message = "Sorry #{sender}, bot can't complete that search: #{error}"

    expect(Mojito, :get, fn _uri ->
      {:error, %{reason: :whatever, message: error}}
    end)

    expect(TMI, :message, fn actual_chat, actual_message ->
      assert actual_chat == chat
      assert actual_message == expected_message
      :ok
    end)

    log =
      capture_log(fn ->
        assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
      end)

    assert log =~ "Error fetching page: #{error}"
  end
end
