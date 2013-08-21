class TasksController < ApplicationController
  before_action :signed_in_user
  before_action :find_task, except: [:create, :new]
  skip_before_filter :verify_authenticity_token, only: [:update]


  def create
    @task = current_project.tasks.build(task_params)
    sym_to_datetime(@task)
    sym_to_str(@task)
    if @task.save
      redirect_to user_project_path(current_user, current_project)
    else
      flash.now[:error] = "Project name should be from 3 to 50 characters"
      render "tasks/new"
    end
  end

  def new
    @task = current_project.tasks.build
  end

  def update
    @task.update_attributes(params[:task])
    sym_to_datetime(@task)
    sym_to_str(@task)
    if @task.save
      redirect_to user_project_path(current_user, current_project)
    else
      flash.now[:error] = params.inspect#"Check your input, name should be from 2 til 50 character, priority should be integer number from 1 to 3"
      render "edit"
    end
  end

  def edit
  end

  def destroy
    @task.destroy
    redirect_to user_project_path(current_user, current_project)
  end

  def upvote
    @task.increment!(:priority) if @task.priority < 3
    redirect_to user_project_path(current_user, current_project)
  end

  def downvote
    @task.decrement!(:priority) if @task.priority > 1
    redirect_to user_project_path(current_user, current_project)
  end

  private

  def current_project
    @project = current_user.projects.where(id: params[:project_id]).first
  end

  def find_task
    @task = current_project.tasks.where(id: params[:id]).first
  end

  def task_params
    params.require(:task).permit(:name, :status, :priority)
  end

  #converts :priority attribute from symbol/string to integer
  def sym_to_str(task)
    task.priority = params[:task][:priority].gsub(/\D/, '').to_i unless params[:task][:priority].nil?
  end

  #converts :deadline attribute from symbol/string to valid datetime
  def sym_to_datetime(task)
    task.deadline = params[:task][:deadline].to_datetime unless params[:task][:deadline].nil?
  end
end
