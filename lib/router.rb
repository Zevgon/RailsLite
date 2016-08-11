require 'byebug'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    req.request_method == @http_method.to_s.upcase &&
    @pattern =~ req.path
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = @pattern.match(req.path)
    route_params = Hash.new
    if match_data
      match_data.names.each do |name|
        route_params[name] = match_data[name]
      end
    end

    p route_params

    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
    # p req.url
    # p @pattern


  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |verb|
    define_method(verb) do |pattern, controller_class, action_name|
      add_route(pattern, verb, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    match = @routes.select { |route| route.matches?(req) }
    match.empty? ? nil : match
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    @routes.each do |route|
      if route.matches?(req)
        route.run(req, res)
        return
      end
    end

    res.status = 404
  end
end
