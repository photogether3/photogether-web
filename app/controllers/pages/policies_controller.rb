class Pages::PoliciesController < PagesController
  def show
  end

  def data_deletion
    render Policies::DataDeletion.new
  end
end
