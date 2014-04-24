if Rails.env.test? || Rails.env.development?
  Docverter.base_url = "http://arturo-convert.herokuapp.com"
else
  Docverter.base_url = "http://arturo-convert.herokuapp.com"
end
