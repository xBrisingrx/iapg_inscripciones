class Authentication::UsersController < ApplicationController
	before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = User.actives
  end

  def show
  end

  def new
    @user = User.new
    @title_modal = "Registrar un usuario"
  end

  def edit
    @title_modal = "Editando al usuasrio #{@user.name}"
  end

  def create
    @user = User.new(user_params)
    activity_history = ActivityHistory.new( action: :create_record, description: "Usuario #{@user.username} registrado", 
      record: @user, date: Time.now, user: current_user )
    respond_to do |format|
      if @user.save && activity_history.save
        format.json { render json: { status: 'success', msg: 'Usuario registrado' }, status: :created }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    activity_history = ActivityHistory.new( action: :update_record, description: "Datos del usuario #{@user.username} actualizados", 
      record: @user, date: Time.now, user: current_user )
    respond_to do |format|
      if @user.update(user_params) && activity_history.save
        # format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render json: { status: 'success', msg: 'Datos del usuario actualizados' }, status: :ok }
      else
        # format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def disable
    user = User.find params[:user_id]
    activity_history = ActivityHistory.new( action: :disable, description: "Usuario #{user.username} dado de baja", 
      record: user, date: Time.now, user: current_user )
    if user.update(active: false) && activity_history.save
      render json: { status: 'success', msg: 'Usuario dado de baja' }, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :username, :email,:password, :password_confirmation, :rol)
    end
end