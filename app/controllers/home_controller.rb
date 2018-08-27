class HomeController< ApplicationController

	def index
		@cities = City.filter(params).page(params[:page]).per(12)
		@categories = Category.all.order(position: :ASC)
		@jobs = Job.all.page(params[:page]).per(12)
		@search = Job.search do
		  keywords(params[:q])
		end
	end
end