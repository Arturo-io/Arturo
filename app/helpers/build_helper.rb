module BuildHelper
  def message(message)
    (message && message[0..49] || "")
  end

  def status_has_spinner?(status)
    parsed_status = status.to_s.downcase
    ['building', 'queued', 'uploading'].any? do |spinner_status|
      parsed_status.include?(spinner_status)
    end
  end

  def build_status(status)
    output = status_has_spinner?(status) ? fa_icon("spinner spin") : ""
    output << " #{status}"
  end
end
