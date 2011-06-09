class PusherSender
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, response = @app.call(env)
    Pusher['admin'].trigger('request', response.url)
    [status, headers, response.body]
  end
end