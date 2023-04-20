class BugsController < ApplicationController
  before_action :set_bug, only: [:edit,:update,:show,:destroy]
  before_action :authenticate_user!

  def new
    @bug = Bug.new()
    #  @bug = Bug.find(params[:id])   # projects/1/bugs/new  
    @project = Project.find_by(id: params[:project_id])  #projects/1
    @developers = @project.users.developer
    unless can? :create, @bug    # projects/1/bugs/new
      flash[:alert] = "You cannot create a bug"
      redirect_to user_path(current_user)
    end
  end

  def create
    @bug = Bug.new(bug_params)
    @bug.creator_id = current_user.id
    @project = Project.find_by(id: params[:project_id]) #projects/1/bugs/new
    @bug.project_id = @project.id
    @developers = @project.users.developer
    if @bug.save
      flash[:success] = "Bug was created successfully"
      redirect_to project_path(@project)
    else 
      render 'new', status: :unprocessable_entity
    end
  end

  def show
    unless can? :show, @bug
      # @bug = Bug.find(params[:id])
      flash[:danger] = "You cannot view other QA's created bugs"
      redirect_to user_path(current_user)
    end
  end

  def edit
    if can? :edit, @bug
      @bug = Bug.find(params[:id])
      @project = Project.find_by(id: params[:project_id])
      @developers = @project.users.developer
      @bug.project_id = @project.id
    else
      flash[:danger] = "You cannot edit other QA's bugs"
      redirect_to user_path(current_user)
    end
  end

  def update
    @project = Project.find_by(id: params[:project_id])
    if @bug.update(bug_params)
      flash[:success] = "Bug was updated successfully"
      redirect_to project_bug_path(@bug)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    if can? :destroy, @bug
      @bug = Bug.find(params[:id]).destroy
      flash[:success] = "Bug was deleted successfully"
      redirect_to user_path(current_user), status: :see_other
    else
      flash[:danger] = "You cannot delete this bug"
      redirect_to root_path
    end
  end

private

  def bug_params
    params.require(:bug).permit(:title, :description, :deadline, :bug_type, :bug_status, :solver_id, :project_id)
  end

  def set_bug
    @bug = Bug.find(params[:id])
  end

end