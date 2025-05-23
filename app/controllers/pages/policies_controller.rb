class Pages::PoliciesController < PagesController
  def show
    render Pages::Policies::Show.new
  end

  def data_deletion
    render Pages::Policies::DataDeletion.new
  end
end
