require 'json'

class Flash

  def initialize(req)
    @req = req
    cookie = req.cookies["_rails_lite_app_flash"]
    @cookie = {}
    if cookie
      @cookie = JSON.parse(cookie)
    end
    @cookie
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_flash(res)
    cookie = { path: "/", value: @cookie.to_json }
    res.set_cookie("_rails_lite_app_flash", cookie)
  end

  def now
    @cookie = Flash.new(@req)
  end

end
