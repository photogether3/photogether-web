class Views::Pages::Layout < Views::Base
  def view_template
    div(class: "max-w-4xl px-4 py-8 mx-auto") do
      yield
    end
  end
end
