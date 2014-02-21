module BuildHelper
  def message(message)
    (message && message[0..24] || "")
  end

  def status_has_spinner?(status)
    parsed_status = status.downcase
    ['building', 'queued'].any? do |spinner_status|
      parsed_status.include?(spinner_status)
    end
  end

  def build_status(status)
    output = status_has_spinner?(status) ? fa_icon("spinner spin") : ""
    output << " #{status}"
  end
end
