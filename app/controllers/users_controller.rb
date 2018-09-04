class UsersController < ApplicationController

	before_action :authenticate_user!
	before_action :params_search

  def params_search
    if params[:key].present?
      redirect_to jobs_path + "?utf8=✓&key=#{params[:key]}&commit=search"
    end
  end

	def update
		if current_user.update(param_user)
  		redirect_to my_page_user_path
  	else
  		render :edit
  	end
	end

	def favorite_user
		job = Job.find(params[:id])
		if current_user.favorited? job
			current_user.remove_favorite job
			redirect_to request.referrer
		else
			current_user.favorite job
			redirect_to request.referrer
		end
	end

	def apply_job
		arr_job_ids = current_user.job_ids
		if arr_job_ids.include? params[:id]
			arr_job_ids.delete(params[:id])
			current_user.update(job_ids: arr_job_ids)
			redirect_to request.referrer
		else
			redirect_to confimation_job_user_path(current_user, Job.find(params[:id]))
		end
	end

	def history_apply
		@jobs_users = JobsUser.where("jobs_users.user_id = ?", current_user)
		@jobs = current_user.jobs.page(params[:page]).per(12)
	end

	def my_page
		@user = User.find(params[:id])
		@jobs_users = JobsUser.where("jobs_users.user_id = ?", current_user)
		@jobs = current_user.jobs.page(params[:page]).per(12)
	end

	def update_cv
		@user = User.find(params[:id])
		ApplyJobMailer.done_apply_user(current_user,Job.find(params[:id])).deliver_now
		ApplyJobMailer.mailer_admin(current_user,Job.find(params[:id])).deliver_now
		redirect_to tks_page_path
	end

	def confimation_job
		@job = Job.find(params[:id])
		@user = User.find(current_user.id)
		arr_job_ids = @user.job_ids
		arr_job_ids.push(@job.id)
		@user.update(job_ids: arr_job_ids)
	end

	def show
		@jobs = current_user.favorited_by_type('Job')
	end

	def update_password
		if current_user.valid_password?(params[:user][:old_password])
      if current_user.update_attributes(param_password)
      else
        redirect_to my_page_user_path
      end
    else
    	render :edit
    end
	end

	private

		def param_user
  		params.require(:user).permit(:name, :phone, :address, :cv)
  	end
    def param_password
      params.require(:user).permit(:password,:password_confirmation)
    end

end
