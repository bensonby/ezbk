class UsersController < ApplicationController
  before_action :require_no_user, :only => [:new, :create]
  before_action :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    #@user = User.new(params[:user])
    @user = User.new(params.require(:user).permit(:email, :login, :password, :password_confirmation))
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params.require(:user).permit(:email, :login, :password, :password_confirmation))
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
