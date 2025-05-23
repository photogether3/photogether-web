class Pages::AccessController < PagesController
  layout -> { Layouts::Error.new }

  def denied
    @client_ip = request.remote_ip
    render Pages::Access::Denied.new(client_ip: @client_ip)
  end
end
