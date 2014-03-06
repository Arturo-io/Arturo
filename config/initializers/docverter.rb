if Rails.env.test?
  Docverter.base_url = "http://localhost:9090"
else
  Docverter.base_url = "http://arturo-convert.herokuapp.com"
end
