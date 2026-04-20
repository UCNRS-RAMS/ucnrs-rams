require "json"

module DevServerStructuredLogging
  ANSI_ESCAPE = /\e\[[\d;]*m/.freeze

  module_function

  def json_formatter
    proc do |severity, timestamp, progname, msg|
      payload = normalize_payload(msg)

      json_line = {
        "@timestamp" => timestamp.utc.iso8601(6),
        "log.level" => severity.to_s.downcase,
        "process.pid" => Process.pid,
      }
      json_line["log.logger"] = progname if progname.present?
      json_line.merge!(payload.transform_keys(&:to_s))

      "#{json_line.to_json}\n"
    end
  end

  def normalize_payload(msg)
    case msg
    when Hash
      ecs_enrich_payload(msg)
    when Exception
      {
        message: strip_ansi(msg.message.to_s),
        error: {
          type: msg.class.name,
          message: strip_ansi(msg.message.to_s),
          stack_trace: Array(msg.backtrace).join("\n"),
        },
      }
    else
      raw = strip_ansi(msg.to_s).strip
      parsed = parse_json_hash(raw)
      parsed ? ecs_enrich_payload(parsed) : { message: raw }
    end
  end

  def parse_json_hash(raw)
    parsed = JSON.parse(raw)
    parsed.is_a?(Hash) ? parsed : nil
  rescue JSON::ParserError
    nil
  end

  def strip_ansi(value)
    value.gsub(ANSI_ESCAPE, "")
  end

  def ecs_enrich_payload(raw_payload)
    payload = raw_payload.transform_keys(&:to_s)

    method = payload["method"]
    path = payload["path"] || payload["original_fullpath"]
    status = payload["status"]
    duration_ms = payload["duration"]
    ip = payload["ip"]
    user_id = payload["user_id"]
    request_id = payload["request_id"]

    payload["http.request.method"] ||= method if method.present?

    if path.present?
      path_only, query = path.to_s.split("?", 2)
      payload["url.original"] ||= path
      payload["url.path"] ||= path_only
      payload["url.query"] ||= query if query.present?
    end

    if status.present?
      status_code = status.to_i
      payload["http.response.status_code"] ||= status_code
      payload["event.outcome"] ||= status_code >= 500 ? "failure" : "success"
    end

    if duration_ms.present?
      payload["event.duration"] ||= (duration_ms.to_f * 1_000_000).to_i
    end

    payload["client.ip"] ||= ip if ip.present?
    payload["source.ip"] ||= ip if ip.present?
    payload["user.id"] ||= user_id.to_s if user_id.present?
    payload["trace.id"] ||= request_id if request_id.present?

    payload["rails.controller"] ||= payload["controller"] if payload["controller"].present?
    payload["rails.action"] ||= payload["action"] if payload["action"].present?
    payload["rails.format"] ||= payload["format"] if payload["format"].present?
    payload["rails.allocations"] ||= payload["allocations"] if payload["allocations"].present?
    payload["rails.view.duration"] ||= payload["view"] if payload["view"].present?
    payload["rails.db.duration"] ||= payload["db"] if payload["db"].present?

    payload
  end
end

