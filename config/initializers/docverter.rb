if Rails.env.test? || Rails.env.development?
  Docverter.base_url = "http://localhost:9292"
else
  Docverter.base_url = "http://arturo-convert.herokuapp.com"
end
