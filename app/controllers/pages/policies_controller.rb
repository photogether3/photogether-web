class Pages::PoliciesController < PagesController
  def show
  end

  def data_deletion
    render Pages::Policies::DataDeletion.new
  end
end
