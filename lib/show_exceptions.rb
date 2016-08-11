require 'erb'

class ShowExceptions
  def initialize(app)
    @app = app
  end

  def app
    @app
  end

  def call(env)
    begin
      app.call(env)
    rescue
      render_exception(RuntimeError)
    end
  end

  private

  def render_exception(e)
    
  end

end
